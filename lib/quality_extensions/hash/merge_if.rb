    duplicates = {}

    people_by_name = {}
    @people.each do |person|
      people_by_name[person.name] ||= []
      people_by_name[person.name] << person
    end
    people_by_name.reject! {|name, people| people.size < 2}
    # Merge elements of this hash back into duplicates, unless it already contains a value (a duplicate) for that value (even if it's for a different key). We don't want to have duplicate duplicates!
    #duplicates.merge_if(people_by_name) {|k, v| !duplicates.values.include?(v) }
    require 'ruby-debug'; debugger
    people_by_name.each {|k, v| duplicates[k] = v unless duplicates.values.include?(v) }

    people_by_wwu_id = {}
    @people.each do |person|
      people_by_wwu_id[person.wwu_id] ||= []
      people_by_wwu_id[person.wwu_id] << person
    end
    people_by_wwu_id.reject! {|wwu_id, people| people.size < 2}
    people_by_name.each {|k, v|
      duplicates[k] = v unless duplicates.values.include?(v)
    }

    people_by_email = {}
    @people.each do |person|
      people_by_wwu_id[person.email_address] ||= []
      people_by_wwu_id[person.email_address] << person
    end
    people_by_email.reject! {|wwu_id, people| people.size < 2}
    people_by_name.each {|k, v|
      duplicates[k] = v unless duplicates.values.include?(v)
    }

    puts "These people have duplicates:"
    duplicates.each do |key, people|
      next if key.blank?
      puts
      puts key
      people.each do |person|
        puts "#{person.id} ('#{person.first_name}' '#{person.last_name}')".ljust(27) + ' ' +
          (person.username || '').ljust(17) + ' ' +
          (person.wwu_id || '').ljust(9) + ' ' +
          person.created_at.strftime("%Y-%m-%d %H:%M") + ' ' +
          (person.last_successful_login_at && person.last_successful_login_at.strftime("%Y-%m-%d %H:%M")).to_s.ljust(16) + ' ' +
          'Profiles: ' + person.profiles.map {|p| "#{p.volume.name} (#{p.user_type.name}, #{p.photos.size} photos)"}.join(', ')
      end
    end

