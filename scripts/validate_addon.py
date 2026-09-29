#!/usr/bin/env python3

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "AddOns" / "PallandoDataCollector"
TOC = ADDON / "PallandoDataCollector.toc"
BOOTSTRAP = ADDON / "Bootstrap.lua"
PROJECT = ROOT / "project.json"

EXPECTED_INTERFACE = "16001"
EXPECTED_VERSION = "0.1.1"
EXPECTED_SAVED_VARIABLES = "PallandoDataCollectorDB"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read_toc():
    lines = TOC.read_text(encoding="utf-8").splitlines()
    metadata = {}
    runtime_files = []

    for line in lines:
        stripped = line.strip()

        if not stripped:
            continue

        if stripped.startswith("##"):
            match = re.match(r"^##\s*([^:]+):\s*(.*)$", stripped)
            if match:
                metadata[match.group(1).strip().lower()] = match.group(2).strip()
            continue

        if stripped.startswith("#"):
            continue

        runtime_files.append(stripped)

    return metadata, runtime_files


def main():
    require(TOC.is_file(), "PallandoDataCollector.toc is missing.")
    require(BOOTSTRAP.is_file(), "Bootstrap.lua is missing.")
    require(PROJECT.is_file(), "project.json is missing.")

    metadata, runtime_files = read_toc()

    require(
        metadata.get("interface") == EXPECTED_INTERFACE,
        f"Expected Interface {EXPECTED_INTERFACE}.",
    )
    require(
        metadata.get("version") == EXPECTED_VERSION,
        f"Expected TOC version {EXPECTED_VERSION}.",
    )
    require(
        metadata.get("savedvariables") == EXPECTED_SAVED_VARIABLES,
        f"Expected SavedVariables {EXPECTED_SAVED_VARIABLES}.",
    )

    for runtime_file in runtime_files:
        normalized = runtime_file.replace("\\", "/")
        require(
            not normalized.startswith("/") and ".." not in Path(normalized).parts,
            f"Runtime path escapes addon directory: {runtime_file}",
        )
        require(
            (ADDON / Path(normalized)).is_file(),
            f"TOC runtime file does not exist: {runtime_file}",
        )

    bootstrap = BOOTSTRAP.read_text(encoding="utf-8")
    version_match = re.search(r'ns\.VERSION\s*=\s*"([^"]+)"', bootstrap)
    require(version_match is not None, "Bootstrap version is missing.")
    require(
        version_match.group(1) == EXPECTED_VERSION,
        "Bootstrap and TOC versions differ.",
    )

    project = json.loads(PROJECT.read_text(encoding="utf-8"))
    require(project.get("schemaVersion") == 1, "Unsupported project schema.")
    require(
        project.get("runtime", {}).get("primaryAddon") == "PallandoDataCollector",
        "Unexpected primary addon.",
    )
    require(
        project.get("runtime", {}).get("addons") == ["PallandoDataCollector"],
        "Unexpected runtime addon list.",
    )

    forbidden_runtime_docs = [
        path
        for path in ADDON.rglob("*")
        if path.is_file() and path.suffix.lower() in {".md", ".txt"}
    ]
    require(
        not forbidden_runtime_docs,
        "Runtime addon contains documentation files.",
    )

    print(
        f"Addon valid: Interface {EXPECTED_INTERFACE}, "
        f"version {EXPECTED_VERSION}, {len(runtime_files)} runtime files."
    )


if __name__ == "__main__":
    main()
