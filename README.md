# ODC Drone Indexer

## Datasets
-----

Francis Cooke Landfill
- Flown ~Aug 2020 with a Mavic Mini 
- 75/75 overlap

La-Vita
- Flown ~Feb 2019 with a Sensefly eBeeX / Aeria X camera

Mill
- Flown ~Dec 2020 with a Mavic Mini

All Ortho Tifs compressed with 'deflate' to reduce size, this could cause issues on some machines.

## Usage
-----

First, ensure the necessary dependencies are installed by running `make install-deps`
in the top-level directory.

The `index_scripts` directory contains the indexing script that works with all of the drone data in this and nested directories.

To add an ODC product, run `datacube product add <path-to-product-definition-file>`.
For example, to add the product for the Francis Cooke landfill when in this directory, run `datacube product add FrancisCookeLandfill/civil_tracker_drone_FrancisCookeLandfill.yaml`.

Once a product is added, index its data with a command like this: `python3 <path-to-indexing-script> <path-to-data> <product-name> <product-type> <platform-code>`.
The product's name is specified in the `name:` field of its YAML file.
For example, for the Francis Cooke landfill product, the indexing command
when in this directory is: `python3 index_scripts/civil_tracker_drone_indexer.py FrancisCookeLandfill/ civil_tracker_drone_FrancisCookeLandfill 'CivilTrackerDrone' 'CivilTracker'`.

You must have ODC installed on the system you run these scripts on.
If some Python packages are not available, try this:
1. Create a new virtual environment and activate it.
   With [Conda](https://docs.conda.io/en/latest/):
   `conda create --name myenv`
   `conda activate myenv`
1. Run `pip3 install <package>` for each missing package (each run of the indexing script should show one of the missing packages if there are any).
1. Deactivate the virtual environment when done adding products and indexing.
   For Conda, use thits command: `conda deactivate`.

You can test the indexed data with the `civil_tracker_drone_notebook.ipynb` notebook.