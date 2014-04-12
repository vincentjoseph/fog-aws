require 'fog/core/collection'
require 'fog/rackspace/models/dns/record'

module Fog
  module DNS
    class Rackspace

      class Records < Fog::Collection

        attribute :zone

        model Fog::DNS::Rackspace::Record

        def all
          requires :zone
          data = service.list_records(zone.identity)
          load(data.body['records'])
        end

        def all!
          requires :zone
          data = []
          total_entries = nil

          begin
            resp = service.list_records(zone.id, :offset => data.size).body
            total_entries ||= resp['totalEntries']
            data += resp['records']
          end while data.size < total_entries

          load(data)
        end

        def get(record_id)
          requires :zone
          data = service.list_record_details(zone.identity, record_id).body
          new(data)
        #nil or empty string will trigger an argument error
        rescue ArgumentError
          nil
        rescue Fog::DNS::Rackspace::NotFound
          nil
        end

        def new(attributes = {})
          requires :zone
          super({ :zone => zone }.merge!(attributes))
        end
      end
    end
  end
end
