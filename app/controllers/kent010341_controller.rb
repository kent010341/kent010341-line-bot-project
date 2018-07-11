class Kent010341Controller < ApplicationController
	protect_from_forgery with: :null_session
#=======================================================================================================================================
# line webhook
	def webhook
		head :ok
	end

#=======================================================================================================================================
# day1~16
	def eat
		render plain: 'eat shit'
	end

	def request_headers
		render plain: request.headers.to_h.reject{ |key, value| key.include? '.' }.map{ |key, value| "#{key}: #{value}" }.sort.join("\n")
	end

	def response_headers
		response.headers['5566'] = 'QQ' 
		render plain: response.headers.to_h.map{ |key, value| "#{key}: #{value}" }.sort.join("\n")
	end

	def request_body
		render plain: request.body
	end

	def show_response_body
		puts "===這是設定前的response.body:#{response.body}==="
		render plain: "from show_response_body"
		puts "===這是設定後的response.body:#{response.body}==="
	end

	def sent_request
		uri = URI('http://localhost:3000/kent010341/eat')
		http = Net::HTTP.new(uri.host, uri.port)
		http_request = Net::HTTP::Get.new(uri)
		http_response = http.request(http_request)

		render plain: JSON.pretty_generate({
			request_class: request.class,
			response_class: response.class,
			http_request_class: http_request.class,
			http_response_class: http_response.class
		})
	end

end
