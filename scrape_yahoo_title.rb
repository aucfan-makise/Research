require 'open-uri'
require 'nokogiri'

result_tag_count = 3

file = File.open(ARGV[0])
isTest = false
unless ARGV[1].nil? then
	isTest = ARGV[1]
end


#doc = Nokogiri::HTML.parse(file, nil)
#
#delete_list = ["script", "meta", "link", "input"]
#delete_list.each do |tag_name|
#	doc.search(tag_name).each do |tag|
#		tag.replace("")
#
#doc.css("body").each do |elm|
#	text = elm.content.gsub(/(\t|\s|\n|\r|\f|\v)/, "")
#


stock_tag = Array.new
in_script = false
in_meta = false
file.each_line do |line|
	if line =~ /table|ul|div/ then
		print "\n"
	end

	if isTest then
		p "before modifying " + line
	end

	if line =~ /<script/ then
		in_script = true
	end
	if in_script && line =~ /<\/script/ then
		in_script = false
	end
	if line =~ /<meta/ then
		in_meta = true
	end
	if in_meta && line =~ />/ then
		in_meta = false
	end

	if in_script || in_meta then
		next
	end

	line = line.strip
	line = line.gsub(/>\s+</, "><")
	line = line.gsub(/<input[^>]+>|<link[^>]+>|<meta[^>]+>|<script[^>]+>[^<]*?<\/script[^>]+>|<img[^>]+>|<link[^>]+>|<meta[^>]+>|<\/script>|<script[^>]+>|<br>|<br[^>]+>|<![^>]+>/, '')
	if isTest then
		p "after modifying " + line
	end
	block_array = line.scan(/^[^<>]+</)
	block_array.concat(line.scan(/>[^<]+</))
	block_array.concat(line.scan(/>[^>]+$/))

	tag = line.scan(/<([a-zA-Z]+)[> ]|<\/([a-zA-Z]+)>/)
	tag.each do |tag_set|
		if isTest then
			p "########################"
			p line
			p "stock_tag = " + stock_tag.to_s
			p "tag_set = " + tag_set.to_s
		end

		unless tag_set[0].nil? then
			stock_tag.push(tag_set[0])

			if isTest then
				p "stock " + tag_set[0]
			end
		else
			if stock_tag.last == tag_set[1] then
				if isTest then
					p "pop " + stock_tag.last
				end

				stock_tag.pop
			else
				print "WWWWWWWWWWWWWWWWWWWWWWWW\n"
				p stock_tag
				p tag_set
				print "WWWWWWWWWWWWWWWWWWWWWWWW\n"
			end
		end

		if isTest then
			p "########################"
		end
	end


	if line !~ /<|>/ && !line.empty? then
		block_array.push(line)
	end

	if isTest then
		print line + "\n"
	end

	block_array.each do |block|
		block = block.gsub(/>|</, "")
		after_block_array = line.scan(/#{block}[^<]*?(<.*)/)
		deleted_tag = Array.new
		after_block_array.each do |after_block|
			if after_block[0].nil? then
				next
			end
			after_block[0].scan(/<\/([^>]+)>/).each do |tag|
				deleted_tag.push(tag[0])
			end
		end

		if isTest then
			print "--------------"
		end
		
		print_tag = ""
		last_num = -1
		result_tag_count.times do |i|
			unless deleted_tag.empty? then
				print_tag += "\t" + deleted_tag.shift.to_s
			else
				if stock_tag[last_num].nil? then
					print_tag += "\t-"
				else
					print_tag += "\t" + stock_tag[last_num]
					last_num -= 1
				end
			end
		end

		print block + print_tag + "\n"
	end
end
