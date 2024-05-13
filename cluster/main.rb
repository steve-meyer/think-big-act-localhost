require "json"
require "pathname"
require_relative "data_stream"
require_relative "cluster_generator"


candidate_file = "data/merge_candidates.tsv"
ClusterGenerator.new(candidate_file).run
