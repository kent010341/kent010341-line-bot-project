require 'line/bot'
class Kent010341Controller < ApplicationController
	protect_from_forgery with: :null_session
#=======================================================================================================================================
# line webhook
	def webhook
		# Line Bot API 物件初始化
		client = Line::Bot::Client.new { |config|
			config.channel_secret = '9160ce4f0be51cc72c3c8a14119f567a'
			config.channel_token = '2ncMtCFECjdTVmopb/QSD1PhqM6ECR4xEqC9uwIzELIsQb+I4wa/s3pZ4BH8hCWeqfkpVGVig/mIPDsMjVcyVbN/WNeTTw5eHEA7hFhaxPmQSY2Cud51LKPPiXY+nUi+QrXy0d7Hi2YUs65B/tVOpgdB04t89/1O/w1cDnyilFU='
		}

		# 取得 reply token
		reply_token = params['events'][0]['replyToken']

		# 設定回覆訊息
		message = {
			type: 'text',
			text: '好哦～好哦～'
		}

		# 傳送訊息
		response = client.reply_message(reply_token, message)

		# 回應 200
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
