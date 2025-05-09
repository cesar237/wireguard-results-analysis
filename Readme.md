# WireGuard Results Analysis

This project provides tools and steps to analyze the results of WireGuard experiments conducted using the [`wireguard-experiment`](https://github.com/YOUR_USERNAME/wireguard-experiment) project. The analysis includes extracting metrics and visualizing them through Jupyter notebooks.

## Prerequisites

Before proceeding, ensure the following dependencies are installed:

* Python 3.8+
* Jupyter Notebook
* Access to results from [Grid5000](https://www.grid5000.fr/)

---

## Analysis Workflow

### Step 1: Get Compressed Results from Grid5000

Retrieve the compressed experiment results archive from your Grid5000 storage. This can typically be done using `scp`:

```bash
scp user@access.grid5000.fr:/path/to/results.tar.gz ./results/
```

### Step 2: Extract the Compressed Results

Navigate to the `results/` directory and extract the archive:

```bash
cd results
tar -xzf results.tar.gz
```

Ensure that the directory structure matches what the scripts expect (e.g., timestamped experiment folders with `raw_data`).

### Step 3: Run Scripts to Extract Metrics

Return to the root of the project and run the metric extraction scripts. These scripts process raw logs and extract key metrics for analysis.

Adjust input/output paths as needed.

### Step 4: Launch Jupyter Notebook for Visualization

Start the Jupyter notebook server:

```bash
jupyter notebook
```

Then, open the provided notebook (`analysis.ipynb`) and run all cells to generate graphs and summaries.

### Step 5: Retrieve Results

After executing the notebook, the generated visualizations and summary data will be saved in the notebook directory (e.g., `./notebooks/output/`).

---

## License

MIT License

---

## Related Projects

* [wireguard-experiment](https://github.com/YOUR_USERNAME/wireguard-experiment) – Scripts to automate WireGuard experiments on Grid5000.
