require 'line/bot'
class Kent010341Controller < ApplicationController
	protect_from_forgery with: :null_session
#=======================================================================================================================================
# line webhook

# config.channel_secret = '120203750409774d33145a57ceb4c6e0'
# config.channel_token = 'kFlOjWJnFvLcZCtPI4ZgZYsrxrHrgsK9bMPjqxEVtP2bJmdIX3OSgstERol/Ze8iKczr1/9qWIhyl6HDkIi1bcEJjJpVov7izgLyFmGKMRnQ6qIcJYhdFo4XxBFIdIY3ZYUzVy9MoR976fS20dZL0wdB04t89/1O/w1cDnyilFU='

	def webhook
		# 學說話
		begin
			reply_text = command_trigger(channel_id, received_text)
		rescue
			nil
		end
		# 關鍵字回覆
		reply_text = keyword_reply(channel_id, received_text) if reply_text.nil?

		# 傳送訊息到 line
		response = reply_to_line(reply_text)

		# 回應 200
		head :ok
	end

#=======================================================================================================================================
# Command Trigger
	def command_trigger(channel_id, received_text)
		# 檢查是否為指令
		return nil unless received_text[0..4] == "kbot "
		# 檢查下一個詞
		received_text = received_text[5..-1]
		# 找尋space位置
		if not received_text.index(" ").nil?
			space_index = received_text.index(" ") 
		elsif received_text.downcase == "help" || received_text.downcase == "h"
			return help_trigger
		else
			return nil
		end
		# 檢查下一個詞為何
		case received_text[0..space_index-1].downcase
			when "keyword", "kw"
				return keyword_trigger(channel_id, received_text[space_index+1..-1])
			else
				return "查無指令，使用kbot help或kbot h查看指令列表"
		end
		#KeywordMapping.create(channel_id: channel_id, keyword: keyword, message: message)
		#"create(channel_id: #{channel_id}, keyword: #{keyword}, message: #{message})"
	end

	def help_trigger
		str_help = "kbot 指令列表：\n" + 
			"kbot help：顯示指令列表及說明\n" + 
			"kbot keyword new [關鍵字] [對應回覆]：新增關鍵字及對應回覆\n" + 
			"kbot keyword remove [關鍵字]：移除該關鍵字\n" + 
			"kbot keyword list：列出所有關鍵字\n" + 
			"=========================================================\n" + 
			"備註：本指令系統有提供縮寫：\n" + 
			"help <=> h\n" + 
			"keyword <=> kw\n" + 
			"[new/remove/list] <=> [n/r/l]"
		return str_help
	end

	def keyword_trigger(channel_id, received_text)
	    # keyword相關指令-----------------------------------
	    def keyword_new(channel_id, received_text)
	    	# 找尋space位置
	    	unless received_text.index(" ").nil?
				space_index = received_text.index(" ") 
			else
				return nil
			end
			# 擷取關鍵字及對應回覆
			if received_text[space_index+1].nil?
				return nil
			else
				keyword = received_text[0..space_index-1]
				reply = received_text[space_index+1..-1]

				KeywordMapping.create(channel_id: channel_id, keyword: keyword, message: message)
				return "create(channel_id: #{channel_id}, keyword: #{keyword}, message: #{message})"
			end
		end

		def keyword_remove(channel_id, received_text)
			return "該功能尚未完成"
		end

		def keyword_list(channel_id)
			return "該功能尚未完成"
		end

		# 主要處理區---------------------------------------
		# 找尋space位置
		if not received_text.index(" ").nil?
			space_index = received_text.index(" ")
		elsif received_text.downcase == "list" || received_text.downcase == "l"
			return keyword_list(channel_id)
		else
			return "查無指令，使用kbot help或kbot h查看指令列表"
		end
		# 檢查下一個字
		case received_text[0..space_index-1].downcase
			when "new", "n"
				return keyword_new(channel_id, received_text[space_index+1..-1])
			when "remove", "r"
				return keyword_remove(channel_id, received_text[space_index+1..-1])
			else
				return "查無指令，使用kbot help或kbot h查看指令列表"
		end
	end
#=======================================================================================================================================
# Other Line Functions
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
