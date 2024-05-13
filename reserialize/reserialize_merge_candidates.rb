require "digest"
require "json"
require "pathname"
require "marc"

TITLE_SUBFIELDS = ["a", "k", "n", "p"]

def merge_key_for(record)
  merge_title = record["245"].subfields.reduce("") do |merge_title, subfield|
    merge_title += " " + subfield.value if TITLE_SUBFIELDS.include?(subfield.code)
    merge_title
  end

  pub_date = record["008"] ? record["008"].value[7, 4] : "----"

  Digest::SHA1.hexdigest(pub_date + " " + merge_title)
end

marc_input_file       = Pathname.new(ARGV[0])
candidate_output_file = marc_input_file.dirname.join("merge-candidates.tsv")

File.open(candidate_output_file, "w+") do |output_file|
  MARC::Reader.new(marc_input_file.to_s).each do |record|
    merge_key = merge_key_for(record)
    raw_data  = {marc: record.to_marc}

    output_file.puts([merge_key, raw_data.to_json].join("\t"))
  end
end
