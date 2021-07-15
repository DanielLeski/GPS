#!/usr/bin/env python

import argparse

from joblib import load
import numpy as np
import scipy.sparse as sp
from sklearn.decomposition import PCA
from sklearn.cluster import DBSCAN
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_blobs
from sklearn import metrics

import matplotlib
matplotlib.use("PDF")
import matplotlib.pyplot as plt

def read_groups(flname):
    groups = dict()
    with open(flname) as fl:
        for ln in fl:
            cols = ln.strip().split(",")
            group_name = cols[0]
            for sample_name in cols[1:]:
                groups[sample_name.replace("-", "_")] = group_name

    return groups
             

def load_matrix(flname):
    return load(flname)

def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--feature-matrices",
                        nargs="+",
                        type=str)

    parser.add_argument("--plot-fl",
                        type=str,
                        required=True)

    parser.add_argument("--groups-fl",
                        type=str,
                        required=True)

    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()

    groups = read_groups(args.groups_fl)
    #Added for labeling each point 
    sample_labels = []
    matrices = []
    labels = []
    for flname in args.feature_matrices:
        matrix = load_matrix(flname)
        for sample_name, group_name in groups.items():
            if sample_name in flname:
                sample_labels.append(sample_name)
                matrices.append(matrix)
                labels.append(group_name)
     
    feature_matrix = np.vstack(matrices)

    pca = PCA(n_components = 2, whiten=True)
    proj = pca.fit_transform(feature_matrix)
    
    
    zz = len(sample_labels)
    labels = np.array(labels)
    sample_labels = np.array(sample_labels)
    for label in set(labels):
        mask = labels == label
        plt.scatter(proj[mask, 0], proj[mask, 1], label=label)
    #Used for subsampling data and using it to determine outliers    
    plt.legend()
    plt.xlabel("Component 1", fontsize=18)
    plt.ylabel("Component 2", fontsize=18)

    plt.savefig(args.plot_fl, DPI=300)

