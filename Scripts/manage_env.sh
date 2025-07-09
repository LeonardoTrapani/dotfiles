#!/usr/bin/env bash
#|---/ /+----------------------------------+---/ /|#
#|--/ /-| Environment Variable Management |--/ /-|#
#|-/ /--| Trapani's Configs               |-/ /--|#
#|/ /---+----------------------------------+/ /---|#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
ENV_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/environment"
PRIVATE_ENV_FILE="$ENV_DIR/private.env"

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
${CYAN}Private Environment Variable Management for Trapani's Configs${NC}

Usage: $0 [COMMAND]

Commands:
    setup       Interactive setup (creates file + prompts to edit)
    init        Initialize private environment configuration (quiet)
    edit        Edit your private environment file (API keys, etc.)
    show        Show current private environment status
    validate    Validate private environment configuration
    backup      Backup private environment file
    aws-creds   Generate AWS credentials file from environment variables
    help        Show this help message

Examples:
    $0 setup                # Interactive setup (recommended)
    $0 init                 # Initialize without prompts
    $0 edit                 # Edit your API keys and sensitive data
    $0 show                 # Display current environment status
    $0 validate             # Check if all required variables are set
    $0 aws-creds            # Generate ~/.aws/credentials from environment variables

Files:
    Private:  $PRIVATE_ENV_FILE (gitignored)

Note: This only manages PRIVATE/SENSITIVE environment variables.
      Public configuration should be handled in your shell config files.

EOF
}

create_template_file() {
    cat > "$PRIVATE_ENV_FILE" << 'EOF'
# Private Environment Variables for Trapani's Configs
# 🔒 SENSITIVE - Keep these secret! This file is gitignored.

# =============================================================================
# Development API Keys 
# =============================================================================

# AI Services
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-your_anthropic_key_here}"
export OPENAI_API_KEY="${OPENAI_API_KEY:-your_openai_key_here}"
export OPENAI_KEY="${OPENAI_API_KEY:-your_openai_key_here}"
export GEMINI_API_KEY="${GEMINI_API_KEY:-your_gemini_key_here}"
export CLAUDE_API_KEY="${CLAUDE_API_KEY:-$ANTHROPIC_API_KEY}"  # Alias for Anthropic

# Cloud Services  
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-your_aws_access_key}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-your_aws_secret_key}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

# AWS Profile-specific Keys
export AWS_ACCESS_KEY_ID_DEV="${AWS_ACCESS_KEY_ID_DEV:-your_aws_dev_access_key}"
export AWS_SECRET_ACCESS_KEY_DEV="${AWS_SECRET_ACCESS_KEY_DEV:-your_aws_dev_secret_key}"
export AWS_ACCESS_KEY_ID_PROD="${AWS_ACCESS_KEY_ID_PROD:-your_aws_prod_access_key}"
export AWS_SECRET_ACCESS_KEY_PROD="${AWS_SECRET_ACCESS_KEY_PROD:-your_aws_prod_secret_key}"

# GitHub (for CLI tools and API access)
export GITHUB_TOKEN="${GITHUB_TOKEN:-your_github_token_here}"
export GH_TOKEN="${GH_TOKEN:-$GITHUB_TOKEN}"

# Database URLs (with credentials)
export DATABASE_URL="${DATABASE_URL:-postgresql://user:pass@localhost:5432/dbname}"
export REDIS_URL="${REDIS_URL:-redis://localhost:6379}"
export MONGODB_URI="${MONGODB_URI:-mongodb://localhost:27017/myapp}"

# Other Services
export STRIPE_API_KEY="${STRIPE_API_KEY:-your_stripe_key_here}"
export SENDGRID_API_KEY="${SENDGRID_API_KEY:-your_sendgrid_key_here}"
export TWILIO_AUTH_TOKEN="${TWILIO_AUTH_TOKEN:-your_twilio_token_here}"

# SSH and GPG
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-}"
export GPG_TTY="${GPG_TTY:-$(tty)}"
EOF
}

# =============================================================================
# Helper Functions (part of manage_env.sh, not the template)
# =============================================================================

# Function to validate required private environment variables
validate_private_env() {
    local missing_vars=()
    
    # Add API keys you actually need - uncomment as needed
    local required_vars=(
        "ANTHROPIC_API_KEY"
        # "GITHUB_TOKEN"
        # "AWS_ACCESS_KEY_ID"
        # "AWS_ACCESS_KEY_ID_DEV"
        # "AWS_ACCESS_KEY_ID_PROD"
    )
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" || "${!var}" == *"your_"* ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo "⚠️  Missing or template values found for:"
        printf "   - %s\n" "${missing_vars[@]}"
        echo "   Edit your private environment file with real values"
        return 1
    fi
    
    echo "✅ Private environment variables validated successfully"
    return 0
}

# Function to generate AWS credentials file from environment variables
generate_aws_credentials() {
    local aws_dir="$HOME/.aws"
    local credentials_file="$aws_dir/credentials"
    
    # Debug: Show current AWS environment variable status
    print_status "Checking AWS environment variables..."
    
    local missing_vars=()
    local template_vars=()
    
    # Check each required variable
    if [[ -z "$AWS_ACCESS_KEY_ID_DEV" ]]; then
        missing_vars+=("AWS_ACCESS_KEY_ID_DEV")
    elif [[ "$AWS_ACCESS_KEY_ID_DEV" == *"your_"* ]]; then
        template_vars+=("AWS_ACCESS_KEY_ID_DEV")
    fi
    
    if [[ -z "$AWS_SECRET_ACCESS_KEY_DEV" ]]; then
        missing_vars+=("AWS_SECRET_ACCESS_KEY_DEV")
    elif [[ "$AWS_SECRET_ACCESS_KEY_DEV" == *"your_"* ]]; then
        template_vars+=("AWS_SECRET_ACCESS_KEY_DEV")
    fi
    
    if [[ -z "$AWS_ACCESS_KEY_ID_PROD" ]]; then
        missing_vars+=("AWS_ACCESS_KEY_ID_PROD")
    elif [[ "$AWS_ACCESS_KEY_ID_PROD" == *"your_"* ]]; then
        template_vars+=("AWS_ACCESS_KEY_ID_PROD")
    fi
    
    if [[ -z "$AWS_SECRET_ACCESS_KEY_PROD" ]]; then
        missing_vars+=("AWS_SECRET_ACCESS_KEY_PROD")
    elif [[ "$AWS_SECRET_ACCESS_KEY_PROD" == *"your_"* ]]; then
        template_vars+=("AWS_SECRET_ACCESS_KEY_PROD")
    fi
    
    # Report issues
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_error "Missing AWS environment variables:"
        printf "   - %s\n" "${missing_vars[@]}"
        print_status "💡 Add these to your private environment file: $PRIVATE_ENV_FILE"
        return 1
    fi
    
    if [[ ${#template_vars[@]} -gt 0 ]]; then
        print_error "AWS environment variables still contain template values:"
        printf "   - %s\n" "${template_vars[@]}"
        print_status "💡 Edit your private environment file and replace template values with real credentials"
        print_status "💡 Run: $0 edit"
        return 1
    fi
    
    print_success "✅ AWS environment variables validated successfully"
    
    # Create .aws directory if it doesn't exist
    mkdir -p "$aws_dir"
    
    # Backup existing credentials file if it exists
    if [[ -f "$credentials_file" ]]; then
        local backup_file="${credentials_file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$credentials_file" "$backup_file"
        print_status "Backed up existing credentials to: $backup_file"
    fi
    
    # Generate the credentials file
    print_status "Generating AWS credentials file..."
    
    cat > "$credentials_file" << EOF
# AWS Credentials - Generated by Trapani's Environment Manager
# 🔒 This file contains sensitive information - keep it secure!
# Generated on: $(date)

[leonardo-datapizza-dev]
aws_access_key_id = $AWS_ACCESS_KEY_ID_DEV
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_DEV

[leonardo-trapani-prod]
aws_access_key_id = $AWS_ACCESS_KEY_ID_PROD
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY_PROD
EOF
    
    # Set appropriate permissions
    chmod 600 "$credentials_file"
    
    print_success "✅ AWS credentials file generated: $credentials_file"
    print_status "💡 You can now use: aws --profile leonardo-datapizza-dev or aws --profile leonardo-trapani-prod"
    
    return 0
}

# Function to show private environment status (without exposing values)
show_private_env() {
    echo "🔒 Private Environment Status:"
    
    # Show API key status (without exposing actual values)
    local api_keys=(
        "ANTHROPIC_API_KEY"
        "OPENAI_API_KEY" 
        # "GITHUB_TOKEN"
        # "AWS_ACCESS_KEY_ID"
        "AWS_ACCESS_KEY_ID_DEV"
        "AWS_SECRET_ACCESS_KEY_DEV"
        "AWS_ACCESS_KEY_ID_PROD"
        "AWS_SECRET_ACCESS_KEY_PROD"
        # "STRIPE_API_KEY"
    )
    
    for key in "${api_keys[@]}"; do
        if [[ -n "${!key}" && "${!key}" != *"your_"* ]]; then
            echo "   $key: ✅ Set"
        else
            echo "   $key: ❌ Not set"
        fi
    done
}

init_env() {
    local quiet_mode="${1:-false}"
    
    if [[ "$quiet_mode" != "true" ]]; then
        print_status "Initializing private environment configuration..."
    fi
    
    # Create environment directory
    mkdir -p "$ENV_DIR"
    
    # Add to gitignore if not already there (always check this)
    local gitignore_file="$(dirname "$SCRIPT_DIR")/.gitignore"
    if [[ -f "$gitignore_file" ]]; then
        if ! grep -q "private.env" "$gitignore_file"; then
            echo "" >> "$gitignore_file"
            echo "# Private environment files with sensitive data" >> "$gitignore_file"
            echo "private.env" >> "$gitignore_file"
            if [[ "$quiet_mode" != "true" ]]; then
                print_success "Added private environment files to .gitignore"
            fi
        fi
    fi
    
    # Check if file exists and create if needed
    if [[ ! -f "$PRIVATE_ENV_FILE" ]]; then
        if [[ "$quiet_mode" != "true" ]]; then
            print_status "Creating private environment file..."
        fi
        create_template_file
        chmod 600 "$PRIVATE_ENV_FILE"  # Restrict permissions
        if [[ "$quiet_mode" != "true" ]]; then
            print_success "Created $PRIVATE_ENV_FILE"
        fi
        return 0  # File was created
    else
        if [[ "$quiet_mode" != "true" ]]; then
            print_status "Private environment file already exists"
        fi
        return 1  # File already existed
    fi
}

setup_interactive() {
    print_status "Setting up private environment variables..."
    
    # Initialize (create file if needed)
    if init_env false; then
        print_success "✅ Created new private environment file"
    else
        print_success "✅ Private environment file already exists"
    fi
    
    echo ""
    print_status "🔧 Would you like to edit your environment file now?"
    print_status "   (This is where you add your API keys like ANTHROPIC_API_KEY, etc.)"
    echo ""
    
    read -p "Edit environment file now? [Y/n]: " -r answer
    case "${answer:-y}" in
    [Yy]|[Yy][Ee][Ss]|"")
        print_status "🔧 Opening environment file for editing..."
        edit_env
        print_success "✅ Environment file editing complete"
        ;;
    *)
        print_status "💡 You can edit it later with: $0 edit"
        ;;
    esac
    
    echo ""
    print_status "🔧 Would you like to generate your AWS credentials file now?"
    print_status "   (This will create ~/.aws/credentials with your AWS profiles)"
    echo ""
    
    read -p "Generate AWS credentials file? [Y/n]: " -r aws_answer
    case "${aws_answer:-y}" in
    [Yy]|[Yy][Ee][Ss]|"")
        # Source the environment file to get the latest variables
        if [[ -f "$PRIVATE_ENV_FILE" ]]; then
            print_status "Loading private environment variables..."
            # shellcheck disable=SC1090
            source "$PRIVATE_ENV_FILE"
            if ! generate_aws_credentials; then
                print_warning "AWS credentials generation failed. You can:"
                print_status "   1. Edit your environment file: $0 edit"
                print_status "   2. Try again later: $0 aws-creds"
            fi
        else
            print_error "Private environment file not found. Cannot generate AWS credentials."
        fi
        ;;
    *)
        print_status "💡 You can generate it later with: $0 aws-creds"
        ;;
    esac
    
    print_status "💡 Remember to restart your shell to load the environment variables"
}

edit_env() {
    if [[ ! -f "$PRIVATE_ENV_FILE" ]]; then
        print_error "Private environment file not found. Run '$0 init' first."
        return 1
    fi
    
    print_status "Opening private environment file for editing..."
    "${EDITOR:-nvim}" "$PRIVATE_ENV_FILE"
}

show_env() {
    print_status "Private Environment Configuration Status:"
    echo ""
    
    # Check if file exists
    if [[ -f "$PRIVATE_ENV_FILE" ]]; then
        echo -e "🔒 Private env file: ${GREEN}✓${NC} $PRIVATE_ENV_FILE"
    else
        echo -e "🔒 Private env file: ${RED}✗${NC} Not found"
    fi
    
    echo ""
    
    # Source and show status if private env exists
    if [[ -f "$PRIVATE_ENV_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$PRIVATE_ENV_FILE"
        show_private_env 2>/dev/null || echo "Environment validation not available"
    fi
}

validate_env() {
    if [[ ! -f "$PRIVATE_ENV_FILE" ]]; then
        print_error "Private environment file not found. Run '$0 init' first."
        return 1
    fi
    
    print_status "Validating private environment configuration..."
    # shellcheck disable=SC1090
    source "$PRIVATE_ENV_FILE"
    
    if validate_private_env 2>/dev/null; then
        print_success "Private environment validation passed!"
    else
        print_warning "Private environment validation found issues"
        return 1
    fi
}

backup_env() {
    local backup_dir="$ENV_DIR/backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    
    mkdir -p "$backup_dir"
    
    if [[ -f "$PRIVATE_ENV_FILE" ]]; then
        cp "$PRIVATE_ENV_FILE" "$backup_dir/private_${timestamp}.env"
        print_success "Backed up private environment to: $backup_dir/private_${timestamp}.env"
    else
        print_warning "No private environment file found to backup"
    fi
}

# Main command handling
case "${1:-help}" in
    setup)
        setup_interactive
        ;;
    init)
        init_env "${2:-false}"
        ;;
    edit)
        edit_env
        ;;
    show)
        show_env
        ;;
    validate)
        validate_env
        ;;
    backup)
        backup_env
        ;;
    aws-creds)
        if [[ -f "$PRIVATE_ENV_FILE" ]]; then
            print_status "Loading private environment variables..."
            # shellcheck disable=SC1090
            source "$PRIVATE_ENV_FILE"
            generate_aws_credentials
        else
            print_error "Private environment file not found. Run '$0 init' first."
            print_status "💡 Initialize with: $0 init"
            print_status "💡 Then edit with: $0 edit"
        fi
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac 
