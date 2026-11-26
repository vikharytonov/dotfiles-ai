#!/usr/bin/env python3
"""PreToolUse hook blocking reads, writes, and shell access to secret files."""

import json
import os
import re
import shlex
import sys

WRITE_TOOLS = {
    "write_file",
    "edit_file",
    "write_to_file",
    "replace_file_content",
    "multi_replace_file_content",
}

SAFE_SUFFIXES = (".example", ".sample", ".template", ".dist", ".pub")

SECRET_PATTERNS = [
    re.compile(r"(^|/)\.env(\.[^/]+)?$", re.IGNORECASE),
    re.compile(r"(^|/)\.dev\.vars$", re.IGNORECASE),
    re.compile(r"\.(pem|key|p12|pfx|jks|keystore)$", re.IGNORECASE),
    re.compile(r"(^|/)id_(rsa|ed25519|ecdsa)(\.[^/]+)?$", re.IGNORECASE),
    re.compile(r"(^|/)\.(ssh|aws|gcp|azure)(/|$)", re.IGNORECASE),
    re.compile(r"(^|/)[^/]*(credentials|service-account)[^/]*\.json$", re.IGNORECASE),
    re.compile(r"\.tfstate(\.[^/]+)?$", re.IGNORECASE),
    re.compile(r"\.tfvars$", re.IGNORECASE),
    re.compile(r"(^|/)(\.kube/config|kubeconfig)$", re.IGNORECASE),
    re.compile(
        r"(^|/)(\.npmrc|\.pypirc|\.netrc|\.git-credentials|\.pgpass|\.my\.cnf|\.htpasswd)$",
        re.IGNORECASE,
    ),
    re.compile(r"(^|/)\.docker/config\.json$", re.IGNORECASE),
    re.compile(r"(^|/)secrets\.[^/]+$", re.IGNORECASE),
    re.compile(r"(^|/)[^/]*secret[^/]*\.(json|ya?ml)$", re.IGNORECASE),
    re.compile(
        r"(^|/)(local_settings\.py|appsettings\.Development\.json|application-local\.ya?ml|config\.local\.[^/]+|master\.key|credentials\.yml\.enc)$",
        re.IGNORECASE,
    ),
]

TAMPER_PATTERNS = [
    re.compile(r"(^|/)\.git/hooks/", re.IGNORECASE),
    re.compile(r"(^|/)hooks\.json$", re.IGNORECASE),
    re.compile(r"(^|/)scripts/file-guard\.py$", re.IGNORECASE),
]


def normalize_path(raw: str) -> str:
    return raw.replace("\\", "/").strip()


def is_safe_exception(path: str) -> bool:
    return path.lower().endswith(SAFE_SUFFIXES)


def matches_any(path: str, patterns: list[re.Pattern[str]]) -> bool:
    norm = normalize_path(path)
    if not norm or is_safe_exception(norm):
        return False
    return any(p.search(norm) for p in patterns)


def extract_file_path(args: dict) -> str:
    for key in ("Path", "TargetFile", "AbsolutePath", "path", "filePath"):
        val = args.get(key)
        if isinstance(val, str) and val.strip():
            return val
    return ""


def is_inside_allowed_roots(path: str, payload: dict) -> bool:
    abs_path = os.path.realpath(os.path.expanduser(path))
    roots = list(payload.get("workspacePaths") or [])
    roots.append("/tmp")
    artifact_dir = payload.get("artifactDirectoryPath")
    if isinstance(artifact_dir, str) and artifact_dir:
        roots.append(artifact_dir)
    for root in roots:
        real_root = os.path.realpath(os.path.expanduser(root))
        if abs_path == real_root or abs_path.startswith(real_root + os.sep):
            return True
    return False


def check_command(command: str) -> str | None:
    try:
        tokens = shlex.split(command)
    except ValueError:
        tokens = command.split()
    for token in tokens:
        cleaned = token.strip("\"'`;|&()<>")
        if "=" in cleaned and not cleaned.startswith("/"):
            cleaned = cleaned.split("=", 1)[1]
        if matches_any(cleaned, SECRET_PATTERNS):
            return cleaned
    return None


def respond(decision: str, reason: str = "") -> None:
    out = {"decision": decision}
    if reason:
        out["reason"] = reason
    sys.stdout.write(json.dumps(out))
    sys.exit(0)


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        respond("ask", "secret-guard could not parse hook payload.")
        return

    tool_call = payload.get("toolCall") or {}
    name = str(tool_call.get("name") or "")
    args = tool_call.get("args") or {}

    if name == "run_command":
        cmd = str(args.get("CommandLine") or args.get("command") or "")
        hit = check_command(cmd)
        if hit:
            respond(
                "deny",
                f"Blocked by dotfiles-ai secret-guard: command references sensitive file '{hit}'.",
            )
        if args.get("BypassSandbox"):
            respond("ask")
        respond("allow")

    file_path = extract_file_path(args)
    if file_path:
        if matches_any(file_path, SECRET_PATTERNS):
            respond(
                "deny",
                f"Blocked by dotfiles-ai secret-guard: '{file_path}' matches sensitive file policy.",
            )
        if name in WRITE_TOOLS and matches_any(file_path, TAMPER_PATTERNS):
            respond(
                "force_ask",
                f"Modifying hook gate '{file_path}' requires explicit user approval.",
            )
        if not is_inside_allowed_roots(file_path, payload):
            respond("ask")

    respond("allow")


if __name__ == "__main__":
    main()
