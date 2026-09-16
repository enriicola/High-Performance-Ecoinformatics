#!/usr/bin/env python3
"""Rank spatial occurrence patterns, assuming WGS84 longitude/latitude input."""

import argparse
import csv
import math
from collections import Counter, defaultdict
from pathlib import Path
from typing import Final

EARTH_RADIUS_M: Final = 6_371_008.8
CENTER_LON: Final = math.radians(10)
CENTER_LAT: Final = math.radians(52)


def project_equal_area(lon, lat):
    """Europe-centred spherical Lambert azimuthal equal-area projection."""
    lon = math.radians(lon)
    lat = math.radians(lat)
    delta_lon = lon - CENTER_LON
    denominator = 1 + (
        math.sin(CENTER_LAT) * math.sin(lat)
        + math.cos(CENTER_LAT) * math.cos(lat) * math.cos(delta_lon)
    )
    if denominator <= 0:
        raise ValueError("coordinate is antipodal to the projection centre")
    scale = math.sqrt(2 / denominator)
    x = EARTH_RADIUS_M * scale * math.cos(lat) * math.sin(delta_lon)
    y = EARTH_RADIUS_M * scale * (
        math.cos(CENTER_LAT) * math.sin(lat)
        - math.sin(CENTER_LAT) * math.cos(lat) * math.cos(delta_lon)
    )
    return x, y


def load_distributions(path, cell_sizes_km):
    species = []
    completed = set()
    current = None

    with path.open(newline="") as handle:
        reader = csv.DictReader(handle)
        required = {"id", "sp_name", "x", "y"}
        if not reader.fieldnames or not required.issubset(reader.fieldnames):
            raise ValueError("input must contain id, sp_name, x and y columns")

        for line_number, row in enumerate(reader, 2):
            name = row["sp_name"]
            if name != current:
                if name in completed:
                    raise ValueError("rows must be grouped by sp_name")
                if species:
                    completed.add(current)
                current = name
                species.append({
                    "name": name,
                    "rows": 0,
                    "seen": set(),
                    "sum_x": 0.0,
                    "sum_y": 0.0,
                    "grids": {size: Counter() for size in cell_sizes_km},
                })

            item = species[-1]
            item["rows"] += 1
            location_id = row["id"]
            if location_id in item["seen"]:
                continue
            item["seen"].add(location_id)

            try:
                lon, lat = float(row["x"]), float(row["y"])
            except ValueError as error:
                raise ValueError("invalid coordinate on line {}".format(line_number)) from error
            if not (-180 <= lon <= 180 and -90 <= lat <= 90):
                raise ValueError("coordinate outside WGS84 bounds on line {}".format(line_number))

            x, y = project_equal_area(lon, lat)
            item["sum_x"] += x
            item["sum_y"] += y
            for size in cell_sizes_km:
                metres = size * 1000
                item["grids"][size][(math.floor(x / metres), math.floor(y / metres))] += 1

    if len(species) < 2:
        raise ValueError("at least two species are required")
    return species


def js_divergence(left, right):
    """Base-2 Jensen-Shannon divergence between sparse count distributions."""
    left_total, right_total = sum(left.values()), sum(right.values())
    if not left_total or not right_total:
        raise ValueError("distributions must not be empty")

    score = 1.0
    smaller, larger = (left, right) if len(left) <= len(right) else (right, left)
    smaller_total, larger_total = (
        (left_total, right_total) if smaller is left else (right_total, left_total)
    )
    for cell, smaller_count in smaller.items():
        larger_count = larger.get(cell)
        if larger_count is None:
            continue
        p, q = smaller_count / smaller_total, larger_count / larger_total
        score += 0.5 * (
            p * math.log2(2 * p / (p + q))
            + q * math.log2(2 * q / (p + q))
            - p
            - q
        )
    return min(1.0, max(0.0, score))


def rank_distributions(distributions):
    count = len(distributions)
    pairwise_totals = [0.0] * count
    for left in range(count):
        for right in range(left + 1, count):
            distance = js_divergence(distributions[left], distributions[right])
            pairwise_totals[left] += distance
            pairwise_totals[right] += distance
    mean_pairwise = [total / (count - 1) for total in pairwise_totals]

    consensus = defaultdict(float)
    for distribution in distributions:
        total = sum(distribution.values())
        for cell, value in distribution.items():
            consensus[cell] += value / total / count
    to_consensus = [js_divergence(distribution, consensus) for distribution in distributions]

    pairwise_order = sorted(range(count), key=lambda i: (mean_pairwise[i], i))
    consensus_order = sorted(range(count), key=lambda i: (to_consensus[i], i))
    pairwise_rank = {index: rank for rank, index in enumerate(pairwise_order, 1)}
    consensus_rank = {index: rank for rank, index in enumerate(consensus_order, 1)}
    return mean_pairwise, to_consensus, pairwise_rank, consensus_rank


def analyse(species, cell_sizes_km):
    rows = []
    for size in cell_sizes_km:
        distributions = [item["grids"][size] for item in species]
        mean_pairwise, to_consensus, pairwise_rank, consensus_rank = rank_distributions(distributions)
        for index, item in enumerate(species):
            locations = len(item["seen"])
            rows.append({
                "cell_km": size,
                "medoid_rank": pairwise_rank[index],
                "consensus_rank": consensus_rank[index],
                "species": item["name"],
                "occurrence_rows": item["rows"],
                "unique_locations": locations,
                "duplicate_rows": item["rows"] - locations,
                "occupied_cells": len(distributions[index]),
                "occupied_area_km2": len(distributions[index]) * size * size,
                "centroid_x_km": item["sum_x"] / locations / 1000,
                "centroid_y_km": item["sum_y"] / locations / 1000,
                "mean_pairwise_jsd": mean_pairwise[index],
                "jsd_to_consensus": to_consensus[index],
            })
    return sorted(rows, key=lambda row: (row["cell_km"], row["medoid_rank"]))


def write_results(path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=rows[0].keys(), lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def write_counts(path, species):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(["count", "species"])
        writer.writerows(sorted((item["rows"], item["name"]) for item in species))


def self_test():
    centre = project_equal_area(10, 52)
    assert abs(centre[0]) < 1e-9 and abs(centre[1]) < 1e-9
    distributions = [Counter({"west": 1}), Counter({"west": 1, "east": 1}), Counter({"east": 1})]
    _, _, ranks, _ = rank_distributions(distributions)
    assert ranks[1] == 1
    assert abs(js_divergence(distributions[0], distributions[0])) < 1e-12
    assert abs(js_divergence(distributions[0], distributions[2]) - 1) < 1e-12


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", nargs="?", type=Path, default=Path("data/input/full_1km_EUNIS.csv"))
    parser.add_argument("--output", type=Path, default=Path("data/output/spatial_species_representativeness.csv"))
    parser.add_argument("--counts-output", type=Path, default=Path("data/output/full_species_counts.csv"))
    parser.add_argument("--cell-km", type=int, nargs="+", default=[5, 10, 20])
    parser.add_argument(
        "--assume-wgs84",
        action="store_true",
        help="acknowledge that input x/y are WGS84 longitude/latitude",
    )
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    self_test()
    if args.self_test:
        print("self-test passed")
        return
    if not args.assume_wgs84:
        parser.error("--assume-wgs84 is required because CSV files do not store CRS metadata")
    if any(size <= 0 for size in args.cell_km):
        parser.error("--cell-km values must be positive")

    species = load_distributions(args.input, args.cell_km)
    rows = analyse(species, args.cell_km)
    write_results(args.output, rows)
    write_counts(args.counts_output, species)
    for size in args.cell_km:
        winner = next(row for row in rows if row["cell_km"] == size and row["medoid_rank"] == 1)
        print("{} km: {} (mean JSD {:.6f}, consensus rank {})".format(
            size, winner["species"], winner["mean_pairwise_jsd"], winner["consensus_rank"]
        ))


if __name__ == "__main__":
    main()
