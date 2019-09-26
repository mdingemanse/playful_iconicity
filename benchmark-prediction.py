# -*- coding: utf-8 -*-
# biltho@mpi.nl

import csv
import click
import logging
import warnings
import numpy as np
import pandas as pd
from scipy.stats import pearsonr
from sklearn.linear_model import Ridge as RR
from sklearn.model_selection import train_test_split as tts

D = 300 # skipgram vector dimension
VECTORDIMENSIONS = ['d_{0}'.format(d) for d in range(D)]

@click.command()
@click.option('--norms', '-n', default='norms-vadc-aoa-en.csv')
@click.option('--vecfile', '-v', default='wiki.en.vec')
@click.option('--source', '-s', default=None)
@click.option('--iterations', '-i', default=10)
@click.option('--holdout', '-h', default=.25)
@click.option('--verbose', default=False, is_flag = True)
def run(norms, vecfile, source, iterations, holdout, verbose):

	# admin
	logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.INFO) if verbose else logging.basicConfig(format='%(levelname)s: %(message)s', level=None)
	warnings.filterwarnings(action="ignore", module="scipy", message="^internal gelsd")

	# norms
	click.secho("Reading norms from: {}".format(norms), fg = 'green')
	data = pd.read_csv(norms).drop_duplicates(subset = 'word')
	data['word'] = data.word.str.lower()
	normset = [col for col in data.columns if col not in ['word', 'Unnamed: 0']]
	logging.info("Found: {}".format(normset))

	# vectors
	click.secho("Reading vectors from: {}".format(vecfile), fg = 'yellow')
	vecs = pd.read_csv(vecfile, sep = ' ', quoting = csv.QUOTE_NONE, skiprows = 1, header = None, names = ['word'] + VECTORDIMENSIONS + ['ignore']).drop_duplicates(subset = ['word']).drop(columns = 'ignore').merge(data, on = 'word', how = 'inner')

	logging.info("Computing predictions")
	results = pd.DataFrame(dict(norm = normset))
	
	# iterate the procedure to accommodate stochastic train // test subsetting
	for t in range(iterations):

		# train // test split
		train, test = tts(vecs, test_size = holdout)

		# data collection
		correlations = []
		ntrains, ntests = [], []
		with click.progressbar(normset, label = "Iteration # {0} (of {1})".format(t + 1, iterations)) as batch:
			for norm in batch:
			
				# format norms
				mu = train[norm].mean()

				# lose any NAs for this norm
				keep = train[norm].notnull()

				# learn an l2 regularised regression
				X, y = train[keep][VECTORDIMENSIONS].values, train[keep][norm].values - mu
				rr = RR()
				rr.fit(X, y)
				
				# save our prediction score & testsizes
				correlations.append(pearsonr(rr.predict(test[test[norm].notnull()][VECTORDIMENSIONS].values), test[test[norm].notnull()][norm].values)[0])
				ntrains.append(X.shape[0])
				ntests.append((test[norm].notnull()).sum())

			results['r_{}'.format(t + 1)] = correlations
			results['train_n_{}'.format(t + 1)] = ntrains
			results['test_n_{}'.format(t + 1)] = ntests
	
	# collect measures
	results = results.set_index('norm')
	results['rmean'] = results[[col for col in results.columns if 'r_' in col]].mean(axis = 1)
	results['rvar'] = results[[col for col in results.columns if 'r_' in col]].var(axis = 1)
	results['#train'] = results[[col for col in results.columns if 'train_n' in col]].mean(axis = 1)
	results['#test'] = results[[col for col in results.columns if 'test_n' in col]].mean(axis = 1)
	results['vectors'] = vecfile.split('/')[-1]
	results['normfile'] = norms.split('/')[-1]
	if source is not None:
		results['source'] = source

	# click save
	logging.info("\n{}".format(results[['rmean', 'rvar', '#test', '#train']].sort_values('rmean')))
	results.to_csv('prediction-results-v={0}-n={1}'.format(vecfile.split('/')[-1].strip('.vec'), norms.split('/')[-1]))
	click.secho("===============================", fg = "yellow")


if __name__ == '__main__':
	run()