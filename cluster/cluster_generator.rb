class ClusterGenerator

  def initialize(filepath)
    @data_stream     = DataStream.new(filepath)
    @output_filepath = Pathname.new(filepath).dirname.join("record-clusters.jsonl")
  end


  def run
    File.open(@output_filepath, "w+") do |output_file|
      @data_stream.each do |title_merge_key, records|
        clusters = cluster_records(records)
        clusters.each {|cluster| output_file.puts(cluster.to_json)}
      end
    end
  end


  private


  # Cluster the manifestation/bib records into work sets
  def cluster_records(records)
    # Map each record to its ID. The next processing will only work with merge IDs and bib IDs
    # and will produce a cluster of bib IDs. This will simply help turn bib ID clusters back
    # into record clusters.
    bibid_record_map = records.map {|record| [record["id"], record]}.to_h

    # Generate "singleton" clusters for records with no merge IDs
    singleton_clusters = records.select {|record| record["mergeIds"].size == 0}
                                .map    {|record| Set[record["id"]]}

    # Generate associations between merge IDs and bib IDs
    mergeid_bibid_map = Hash.new {|hash, merge_id| hash[merge_id] = Set.new}
    records.each {|record| record["mergeIds"].each {|merge_id| mergeid_bibid_map[merge_id] << record["id"]}}

    # Consolidate the overlapping bib ID clusters
    bibid_clusters = consolidate_bibid_clusters(mergeid_bibid_map)

    # Remap the ID clusters back to clusters of full records
    (singleton_clusters + bibid_clusters).map {|cluster| cluster.map {|bib_id| bibid_record_map[bib_id]}}
  end


  # For each group of bib IDs associated with a merge ID, look for an existing cluster with
  # overlap, otherwise add this unique bib_ids set as its own cluster.
  def consolidate_bibid_clusters(mergeid_bibid_map)
    bibid_clusters = Array.new

    mergeid_bibid_map.each do |merge_id, mergeid_cluster|
      # puts "Processing bib IDs for merge ID #{merge_id}: #{mergeid_cluster.inspect}"
      overlap_found = false
      bibid_clusters.each_with_index do |cluster, index|
        # Use basic set theory subtraction to identify overlap.
        if (cluster - mergeid_cluster).size < cluster.size
          # puts "Merging with #{bibid_clusters[index].inspect}"
          overlap_found = true
          bibid_clusters[index] += mergeid_cluster
        end
      end

      # If no overlap has been found, create a new cluster of bib IDs for the current merge ID group
      unless overlap_found
        # puts "No overlap found, creating new bib ID cluster for #{mergeid_cluster.inspect}"
        bibid_clusters << mergeid_cluster
      end
    end

    bibid_clusters
  end

end
