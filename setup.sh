#!/bin/bash

if [ -f config.env ]; then
    echo "config.env already exists, skipping"
    echo "Please delete config.env if you want to re-run this script"
    exit 0
fi

echo "Models available:"
echo "[1] codegen-350M-mono (2GB total VRAM required; Python-only)"
echo "[2] codegen-350M-multi (2GB total VRAM required; multi-language)"
echo "[3] codegen-6B-mono (13GB total VRAM required; Python-only)"
echo "[4] codegen-6B-multi (13GB total VRAM required; multi-language)"
echo "[5] codegen-16B-mono (32GB total VRAM required; Python-only)"
echo "[6] codegen-16B-multi (32GB total VRAM required; multi-language)"
# Read their choice
read -p "Enter your choice [4]: " MODEL_NUM

# Convert model number to model name
case $MODEL_NUM in
    1) MODEL="codegen-350M-mono" ;;
    2) MODEL="codegen-350M-multi" ;;
    3) MODEL="codegen-6B-mono" ;;
    4) MODEL="codegen-6B-multi" ;;
    5) MODEL="codegen-16B-mono" ;;
    6) MODEL="codegen-16B-multi" ;;
    *) MODEL="codegen-6B-multi" ;;
esac

# Read number of GPUs
read -p "Enter number of GPUs [1]: " NUM_GPUS
NUM_GPUS=${NUM_GPUS:-1}

# Read model directory
read -p "Where do you want to save the model [$(pwd)/models]? " MODEL_DIR
if [ -z "$MODEL_DIR" ]; then
    MODEL_DIR="$(pwd)/models"
fi

# Write config.env
echo "MODEL=${MODEL}" > config.env
echo "NUM_GPUS=${NUM_GPUS}" >> config.env
echo "MODEL_DIR=${MODEL_DIR}" >> config.env

if [ -d "$MODEL_DIR"/"${MODEL}"-${NUM_GPUS}gpu ]; then
    echo "Converted model for ${MODEL}-${NUM_GPUS}gpu already exists, skipping"
    echo "Please delete ${MODEL_DIR}/${MODEL}-${NUM_GPUS}gpu if you want to re-convert it"
    exit 0
fi

# Create model directory
mkdir -p "${MODEL_DIR}"

echo "Downloading and converting the model, this will take a while..."
docker run --rm -v ${MODEL_DIR}:/models -e MODEL=${MODEL} -e NUM_GPUS=${NUM_GPUS} moyix/model_conveter:latest
echo "Done! Now run ./launch.sh to start the FauxPilot server."
