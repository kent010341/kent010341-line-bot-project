require 'line/bot'
class Kent010341Controller < ApplicationController
	protect_from_forgery with: :null_session
#=======================================================================================================================================
# line webhook

# config.channel_secret = '120203750409774d33145a57ceb4c6e0'
# config.channel_token = 'kFlOjWJnFvLcZCtPI4ZgZYsrxrHrgsK9bMPjqxEVtP2bJmdIX3OSgstERol/Ze8iKczr1/9qWIhyl6HDkIi1bcEJjJpVov7izgLyFmGKMRnQ6qIcJYhdFo4XxBFIdIY3ZYUzVy9MoR976fS20dZL0wdB04t89/1O/w1cDnyilFU='

	def webhook
		# 學說話
		reply_text = command_trigger(channel_id, received_text)

		# 關鍵字回覆
		reply_text = keyword_reply(channel_id, received_text) if reply_text.nil?

		# 傳送訊息到 line
		response = reply_to_line(reply_text)

		# 回應 200
		head :ok
	end

	# 學說話
	def command_trigger(channel_id, received_text)
		#如果開頭不是kbot，跳出
		return nil unless received_text[0..4].downcase == 'kbot '

		received_text = received_text[5..-1]
		space_index = received_text.index(' ')

		case received_text[0..space_index-1].downcase
			when 'help', 'h'
				print_help
			when 'keyword', 'kw'
				keyword_trigger(channel_id, received_text[space_index+1..-1])
			when 'notification', 'nf'
				notification_trigger(channel_id, received_text[space_index+1..-1])
			else
				return nil
		end
	end

	# 頻道 ID
	def channel_id
		source = params['events'][0]['source']
		source['groupId'] || source['roomId'] || source['userId']
	end

	# 取得對方說的話
	def received_text
		message = params['events'][0]['message']
		message['text'] unless message.nil?
	end

	# 關鍵字回覆
	def keyword_reply(channel_id, received_text)
		message = KeywordMapping.where(channel_id: channel_id, keyword: received_text).last&.message
	    return message unless message.nil?
	    KeywordMapping.where(keyword: received_text).last&.message
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

#==========================================================================
  	# Command Trigger
  	def print_help
  		str_help = 
  			"kbot 功能清單：\n"
  			"kbot help：列出功能清單\n" + 
  			"kbot keyword (new/remove/list) [關鍵詞] [對應回覆]：新增/移除/列出關鍵字回覆\n" + 
  			"kbot notification (new/remove/list)：功能尚未開放\n" + 
  			"可使用對應縮寫：\n" + 
  			"help <=> h\n" + 
  			"keyword <=> kw\n" + 
  			"notification <=> nf\n" + 
  			"(new/remove/list) <=> (n/r/l)"
  		return str_help
  	end

  	def keyword_trigger(channel_id, remain_text)
  		space_index = remain_text.index(' ')
  		case remain_text[0..space_index-1].downcase
  			when 'new', 'n'
  				keyword_new(channel_id, remain_text[space_index+1..-1])
  			when 'remove', 'r'
  				keyword_remove(channel_id, remain_text[space_index+1..-1])
  			when 'list', 'l'
  				keyword_list(channel_id, remain_text[space_index+1..-1])
  			else
  				return nil
  		end
  	end

  	def keyword_new(channel_id, r_text)
  		space_index = r_text.index(' ')
  		keyword = r_text[0..space_index-1]
  		reply = r_text[space_index+1..-1]

  		KeywordMapping.create(channel_id: channel_id, keyword: keyword, message: message)
		'新增關鍵字：#{keyword}，對應回覆：#{reply}'
  	end

  	def keyword_remove(channel_id, r_text)
  		'功能尚未開放'
  	end

  	def keyword_list(channel_id, r_text)
		'功能尚未開放'
  	end

  	def notification_trigger(channel_id, remain_text)
  		space_index = remain_text.index(' ')
  		case remain_text[0..space_index-1].downcase
  			when 'new', 'n'
  				notification_new(channel_id, remain_text[space_index+1..-1])
  			when 'remove', 'r'
  				notification_remove(channel_id, remain_text[space_index+1..-1])
  			when 'list', 'l'
  				notification_list(channel_id, remain_text[space_index+1..-1])
  			else
  				return nil
  		end
  	end

  	def notification_new(channel_id, r_text)
		'功能尚未開放'
  	end

  	def notification_remove(channel_id, r_text)
		'功能尚未開放'
  	end

  	def notification_list(channel_id, r_text)
		'功能尚未開放'
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
