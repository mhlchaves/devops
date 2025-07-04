#!/bin/bash -eu

# ------------------------------------------------------------------------------
# Script: new_version.sh
#
# Description:
#   Implements semantic versioning updates based on input parameters.
#   Can be sourced or run with arguments, or tested with --test.
#
# Usage:
#   ./new_version.sh <branch> <version> <operator>
#   ./new_version.sh --test
#
# Operators:
#   - major        → increment major, reset minor & patch
#   - minor        → increment minor, reset patch
#   - patch        → increment patch
#   - buildnumber  → increment or add suffix.buildnumber
#   - release      → remove suffix.buildnumber
# ------------------------------------------------------------------------------

#!/bin/bash

# ------------------------------------------------------------------------------
# Function: new_version
# Semantic version increment function.
# ------------------------------------------------------------------------------

new_version() {
  local branch="$1"
  local version="$2"
  local operator="$3"

  # Validate branch
  if [[ "$branch" != "main" && ! "$branch" =~ ^release\/[0-9]+\.[0-9]+$ ]]; then
    echo "Error: invalid branch '$branch'" >&2
    return 1
  fi

  # Validate version format and extract parts
  local regex='^([0-9]+)\.([0-9]+)\.([0-9]+)(-([a-z]+)\.?([0-9]+)?)?$'
  if [[ "$version" =~ $regex ]]; then
    local ver_major="${BASH_REMATCH[1]}"
    local ver_minor="${BASH_REMATCH[2]}"
    local ver_patch="${BASH_REMATCH[3]}"
    local full_suffix="${BASH_REMATCH[4]}"
    local ver_suffix="${BASH_REMATCH[5]}"
    local ver_build="${BASH_REMATCH[6]}"
  else
    echo "Error: invalid version format '$version'" >&2
    return 1
  fi

  # Validate operator
  if [[ ! "$operator" =~ ^(major|minor|patch|release|buildnumber)$ ]]; then
    echo "Error: invalid operator '$operator'" >&2
    return 1
  fi

  case "$operator" in
    major)
      ver_major=$((ver_major + 1))
      ver_minor=0
      ver_patch=0
      echo "${ver_major}.${ver_minor}.${ver_patch}"
      ;;
    minor)
      ver_minor=$((ver_minor + 1))
      ver_patch=0
      echo "${ver_major}.${ver_minor}.${ver_patch}"
      ;;
    patch)
      ver_patch=$((ver_patch + 1))
      echo "${ver_major}.${ver_minor}.${ver_patch}"
      ;;
    buildnumber)
      if [[ -n "$ver_suffix" ]]; then
        if [[ "$branch" == "main" && "$ver_suffix" != "db" ]] || [[ "$branch" =~ ^release\/ && "$ver_suffix" != "rc" ]]; then
          echo "Error: invalid suffix '$ver_suffix' for branch '$branch'" >&2
          return 1
        fi
        ver_build=${ver_build:-0}
        ver_build=$((ver_build + 1))
        echo "${ver_major}.${ver_minor}.${ver_patch}-${ver_suffix}.${ver_build}"
      else
        if [[ "$branch" == "main" ]]; then
          echo "${ver_major}.${ver_minor}.${ver_patch}-db.1"
        elif [[ "$branch" =~ ^release\/ ]]; then
          echo "${ver_major}.${ver_minor}.${ver_patch}-rc.1"
        else
          echo "Error: unsupported branch for buildnumber" >&2
          return 1
        fi
      fi
      ;;
    release)
      echo "${ver_major}.${ver_minor}.${ver_patch}"
      ;;
  esac
}
