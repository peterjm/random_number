#!/usr/bin/env python3

import argparse
import random


def generate_random_number(multiplier=1):
    """Generate a random number between 0 and 1, multiplied by the given multiplier."""
    return random.random() * multiplier


def main():
    parser = argparse.ArgumentParser(
        description="Generate a random number with an optional multiplier"
    )
    parser.add_argument(
        "--multiplier",
        type=float,
        default=1.0,
        help="Multiplier for the random number (default: 1.0)",
    )

    args = parser.parse_args()
    result = generate_random_number(args.multiplier)
    print(result)


if __name__ == "__main__":
    main()
