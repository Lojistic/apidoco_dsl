module ApidocoDsl
  module Generators
    class DocumentationGenerator < Rails::Generators::Base
      desc "Generate static JSON documentation for your API endpoints"

      def generate_docs
        docs = ApidocoDsl.fetch_docs
        base_path = Apidoco.base_path

        docs.each do |doc|
          doc_path = "#{base_path}/#{doc.doc_folder}/#{doc.doc_file}.json"
          create_file(doc_path, doc.to_json, force: true)
        end
      end
    end
  end
end

