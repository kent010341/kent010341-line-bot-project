require 'line/bot'
class Kent010341Controller < ApplicationController
	protect_from_forgery with: :null_session
#=======================================================================================================================================
# line webhook

# config.channel_secret = '120203750409774d33145a57ceb4c6e0'
# config.channel_token = 'kFlOjWJnFvLcZCtPI4ZgZYsrxrHrgsK9bMPjqxEVtP2bJmdIX3OSgstERol/Ze8iKczr1/9qWIhyl6HDkIi1bcEJjJpVov7izgLyFmGKMRnQ6qIcJYhdFo4XxBFIdIY3ZYUzVy9MoR976fS20dZL0wdB04t89/1O/w1cDnyilFU='

	def webhook
		# 設定回覆文字
		reply_text = keyword_reply(received_text)

		# 傳送訊息到 line
		response = reply_to_line(reply_text)

		# 回應 200
		head :ok
	end

	# 取得對方說的話
	def received_text
		message = params['events'][0]['message']
		message['text'] unless message.nil?
	end

	# 關鍵字回覆
	def keyword_reply(received_text)
		# 學習紀錄表
		keyword_mapping = {
			'QQ' => '幫Q',
			'安' => '安安'
		}

		# 查表
		keyword_mapping[received_text]
	end

		# 傳送訊息到 line
	def reply_to_line(reply_text)
		return nil if reply_text.nil?

		# 取得 reply token
		reply_token = params['events'][0]['replyToken']

		# 設定回覆訊息
		message = {
			type: 'text',
			text: reply_text
		} 

		# 傳送訊息
		line.reply_message(reply_token, message)
	end

	# Line Bot API 物件初始化
	def line
		@line ||= Line::Bot::Client.new { |config|
			config.channel_secret = '120203750409774d33145a57ceb4c6e0'
			config.channel_token = 'kFlOjWJnFvLcZCtPI4ZgZYsrxrHrgsK9bMPjqxEVtP2bJmdIX3OSgstERol/Ze8iKczr1/9qWIhyl6HDkIi1bcEJjJpVov7izgLyFmGKMRnQ6qIcJYhdFo4XxBFIdIY3ZYUzVy9MoR976fS20dZL0wdB04t89/1O/w1cDnyilFU='
		}
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
