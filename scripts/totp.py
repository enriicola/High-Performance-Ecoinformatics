#!/usr/bin/env python3
"""Generate the six-digit TOTP used by the CINECA login script."""

import base64
import binascii
import hashlib
import hmac
import struct
import sys
import time
from pathlib import Path


def totp(secret: str, timestamp: int) -> str:
    secret = "".join(secret.split())
    if not secret:
        raise ValueError("empty secret")
    secret += "=" * (-len(secret) % 8)
    key = base64.b32decode(secret, casefold=True)
    counter = struct.pack(">Q", timestamp // 30)
    digest = hmac.new(key, counter, hashlib.sha1).digest()
    offset = digest[-1] & 0x0F
    code = int.from_bytes(digest[offset : offset + 4], "big") & 0x7FFFFFFF
    return f"{code % 1_000_000:06d}"


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit(f"Usage: {sys.argv[0]} SECRET_FILE | --self-test")
    if sys.argv[1] == "--self-test":
        # RFC 6238 SHA-1 test at t=59 is 94287082; this CLI emits six digits.
        result = totp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", 59)
        if result != "287082":
            raise SystemExit(f"RFC 6238 self-test failed: {result}")
        print("RFC 6238 self-test passed")
        return

    try:
        secret = Path(sys.argv[1]).read_text(encoding="ascii")
        print(totp(secret, int(time.time())))
    except (OSError, UnicodeError, ValueError, binascii.Error) as error:
        raise SystemExit(f"Cannot generate TOTP: {error}") from error


if __name__ == "__main__":
    main()
