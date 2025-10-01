#!/bin/bash

MANIFESTS_DIR=${1:-"manifests"}

set -e -u -o pipefail

# Function to extract version from ArgoCD app manifest
get_chart_version() {
    local app_file="$1"
    yq eval '.spec.sources[] | select(.chart) | .targetRevision' "$app_file" 2>/dev/null || echo ""
}

# Function to extract chart name from ArgoCD app manifest
get_chart_name() {
    local app_file="$1"
    yq eval '.spec.sources[] | select(.chart) | .chart' "$app_file" 2>/dev/null || echo ""
}

# Function to extract repository from ArgoCD app manifest
get_chart_repo() {
    local app_file="$1"
    yq eval '.spec.sources[] | select(.chart) | .repoURL' "$app_file" 2>/dev/null || echo ""
}

# Function to extract namespace from ArgoCD app manifest
get_namespace() {
    local app_file="$1"
    yq eval '.spec.destination.namespace' "$app_file" 2>/dev/null || echo "default"
}

# Function to extract app name from ArgoCD app manifest
get_app_name() {
    local app_file="$1"
    yq eval '.metadata.name' "$app_file" 2>/dev/null || echo ""
}

# Function to extract release name from ArgoCD app manifest
get_release_name() {
    local app_file="$1"
    local release_name=$(yq eval '.spec.sources[] | select(.chart) | .helm.releaseName' "$app_file" 2>/dev/null)
    if [ -z "$release_name" ] || [ "$release_name" = "null" ]; then
        # Fallback to app name if no release name specified
        get_app_name "$app_file"
    else
        echo "$release_name"
    fi
}

# Function to extract values files from ArgoCD app manifest
get_values_files() {
    local app_file="$1"
    local values_files=""
    local current_dir=$(pwd)
    
    # Extract valueFiles from helm section
    local helm_values=$(yq eval '.spec.sources[] | select(.chart) | .helm.valueFiles[]' "$app_file" 2>/dev/null)
    
    if [ -n "$helm_values" ]; then
        while IFS= read -r values_file; do
            # Convert ArgoCD $values reference to actual file path
            if [[ "$values_file" == *"\$values/"* ]]; then
                # Remove $values/ prefix and convert to relative path
                # Handle both single and double slashes
                local_path=$(echo "$values_file" | sed 's|$values/kubernetes/oci/compute/cluster//*||')
                if [ -f "$local_path" ]; then
                    # Convert to absolute path
                    absolute_path="$current_dir/$local_path"
                    values_files="$values_files --values $absolute_path"
                fi
            elif [ -f "$values_file" ]; then
                # Convert to absolute path
                absolute_path="$current_dir/$values_file"
                values_files="$values_files --values $absolute_path"
            fi
        done <<< "$helm_values"
    fi
    
    echo "$values_files"
}

# Function to extract helm parameters from ArgoCD app manifest
get_helm_parameters() {
    local app_file="$1"
    local parameters=""
    
    # Extract helm parameters
    local helm_params=$(yq eval '.spec.sources[] | select(.chart) | .helm.parameters[]' "$app_file" 2>/dev/null)
    
    if [ -n "$helm_params" ]; then
        while IFS= read -r param; do
            local name=$(echo "$param" | yq eval '.name' -)
            local value=$(echo "$param" | yq eval '.value' -)
            if [ -n "$name" ] && [ -n "$value" ]; then
                parameters="$parameters --set $name=$value"
            fi
        done <<< "$helm_params"
    fi
    
    echo "$parameters"
}

# Function to extract path-based sources from ArgoCD app manifest
get_path_sources() {
    local app_file="$1"
    local paths=""
    
    # Extract paths from sources (both single source and multiple sources)
    local source_paths=$(yq eval '.spec.source.path // (.spec.sources[] | select(.path) | .path)' "$app_file" 2>/dev/null)
    
    if [ -n "$source_paths" ]; then
        while IFS= read -r path; do
            if [ -n "$path" ] && [ "$path" != "null" ]; then
                # Convert full path to relative path
                local_path=$(echo "$path" | sed 's|kubernetes/oci/compute/cluster/||')
                if [ -d "$local_path" ]; then
                    paths="$paths $local_path"
                fi
            fi
        done <<< "$source_paths"
    fi
    
    echo "$paths"
}

# Function to check if an ArgoCD app is kustomize-based
is_kustomize_app() {
    local app_file="$1"
    local path_source=$(get_path_sources "$app_file")
    
    if [ -n "$path_source" ]; then
        # Check if the path contains kustomization files
        for path in $path_source; do
            if [ -f "$path/kustomization.yaml" ] || [ -f "$path/kustomize.yaml" ]; then
                return 0
            fi
        done
    fi
    
    return 1
}

# Function to process path-based ArgoCD applications
process_path_based_app() {
    local app_file="$1"
    local app_name=$(get_app_name "$app_file")
    local paths=$(get_path_sources "$app_file")
    
    if [ -z "$paths" ]; then
        return
    fi
    
    echo "Processing path-based application: $app_name"
    
    for path in $paths; do
        if [ ! -d "$path" ]; then
            continue
        fi
        
        local output_dir="$MANIFESTS_DIR/$app_name"
        mkdir -p "$output_dir"
        
        if is_kustomize_app "$app_file"; then
            echo "  Generating kustomize manifests from: $path"
            kubectl kustomize "$path" --output "$output_dir/manifests.yaml" || {
                echo "Error: Failed to generate kustomize manifests from $path"
                exit 1
            }
        else
            echo "  Copying manifests from: $path"
            cp "$path"/*.yaml "$output_dir/" || {
                echo "Error: Failed to copy manifests from $path"
                exit 1
            }
        fi
    done
}

# Check if yq is available
if ! command -v yq &> /dev/null; then
    echo "yq is required but not installed. Please install it first."
    echo "Install with: sudo snap install yq"
    exit 1
fi

mkdir -p "$MANIFESTS_DIR"

# Auto-detect and process ArgoCD app files
echo "Auto-detecting ArgoCD applications..."
find argocd-apps -name "*.yaml" -type f | while read -r app_file; do
    if [ ! -f "$app_file" ]; then
        continue
    fi
    
    # Skip certain files
    case "$(basename "$app_file")" in
        "argocd-infra-root-app.yaml"|"argocd-manifests.yaml")
            continue
            ;;
    esac
    
    app_name=$(get_app_name "$app_file")
    chart_name=$(get_chart_name "$app_file")
    
    # Check if this is a chart-based application
    if [ -n "$chart_name" ]; then
        # Process as Helm chart
        release_name=$(get_release_name "$app_file")
        chart_version=$(get_chart_version "$app_file")
        chart_repo=$(get_chart_repo "$app_file")
        namespace=$(get_namespace "$app_file")
        
        # Skip if no chart information
        if [ -z "$chart_version" ] || [ -z "$chart_repo" ]; then
            echo "Error: Missing chart information for $app_file"
            echo "Chart: $chart_name, Version: $chart_version, Repo: $chart_repo"
            exit 1
        fi
        
        # Extract values files from ArgoCD app manifest
        values_args=$(get_values_files "$app_file")
        
        # Extract helm parameters from ArgoCD app manifest
        helm_params=$(get_helm_parameters "$app_file")
        
        # Special handling for cert-manager CRDs
        crds_args=""
        if [ "$chart_name" == "cert-manager" ]; then
            crds_args="--set crds.enabled=true"
        fi
        
        echo "Generating manifests for $app_name (chart: $chart_name, version: $chart_version, release: $release_name)..."
        
        # Build helm template command using --repo
        helm_cmd="helm template $release_name $chart_name --version $chart_version --repo $chart_repo --namespace $namespace"
        
        if [ -n "$values_args" ]; then
            helm_cmd="$helm_cmd $values_args"
        fi
        
        if [ -n "$helm_params" ]; then
            helm_cmd="$helm_cmd $helm_params"
        fi
        
        if [ -n "$crds_args" ]; then
            helm_cmd="$helm_cmd $crds_args"
        fi
        
        helm_cmd="$helm_cmd --output-dir $(pwd)/$MANIFESTS_DIR"
        
        # Execute the command in a temporary directory to avoid conflicts
        echo "Executing: $helm_cmd"
        (
            cd /tmp
            eval "$helm_cmd"
        ) || {
            echo "Error: Failed to generate manifests for $app_name"
            echo "Command: $helm_cmd"
            exit 1
        }
        
        # Process any additional path-based sources (like cert-manager clusterissuers)
        process_path_based_app "$app_file"
    else
        # Process as path-based application
        process_path_based_app "$app_file"
    fi
done

echo "All manifests generated successfully!"
echo "Generated manifests are available in: $MANIFESTS_DIR"
