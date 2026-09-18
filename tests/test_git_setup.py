"""Run with python3 tests/test_git_setup.py; Git configuration stays in a temporary repo."""
from pathlib import Path
import subprocess
import tempfile

setup = Path(__file__).resolve().parents[1] / "scripts" / "git-setup.sh"
expected = {
    "core.filemode": "false",
    "core.autocrlf": "false",
    "core.hooksPath": ".githooks",
}

with tempfile.TemporaryDirectory() as repo:
    subprocess.run(["git", "init", "-q", repo], check=True)
    for key, value in expected.items():
        for _ in range(2):
            subprocess.run(
                ["git", "-C", repo, "config", "--local", "--add", key, value],
                check=True,
            )
    for _ in range(2):
        subprocess.run(["bash", str(setup)], cwd=repo, check=True)
        for key, value in expected.items():
            actual = subprocess.check_output(
                ["git", "-C", repo, "config", "--local", "--get-all", key],
                text=True,
            )
            assert actual.splitlines() == [value], (key, actual)
print("Git setup handles duplicates and repeated runs.")
