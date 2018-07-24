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
		#正規表示式列表
		dict_reg = {
			"h" => /^\s+help|h\b\s*(.*)/,
        	"kw" => /^\s+keyword|kw\b\s+(.*)/,
        	"debug" => /^\s+debug|d\b/
		}

		# 檢查是否為指令
		return nil unless received_text[0..4] == "kbot "
		# 裁切文字
		received_text = received_text[4..-1]
		# 判斷下個字
		if received_text =~ dict_reg["h"]
			if $1 == ""
				return help_trigger
			else
				return help_trigger($1)
			end
		elsif received_text =~ dict_reg["kw"]
			return keyword_trigger(channel_id, $1)
		elsif received_text =~ dict_reg["debug"]
			return debug_func(channel_id)
		else
			return "查無指令，使用kbot help或kbot h查看指令列表"
		end
	end

	def debug_func(channel_id)
		str = nil

		puts "======================================================="
		puts KeywordMapping.find_by_sql("select * from keyword_mappings where channel_id = #{channel_id}")
		puts "======================================================="

		return str
	end

	def help_trigger(selection=nil)
		str_output = ""

		str_title = "kbot 指令列表："
		str_kw = "kbot keyword new [關鍵字] [對應回覆]：新增關鍵字及對應回覆\n" + 
			"kbot keyword remove [編號(用list查詢)]：移除該關鍵字\n" + 
			"kbot keyword remove /all：移除全部關鍵字\n" + 
			"kbot keyword list：列出所有關鍵字"
		str_help = "kbot help：顯示指令列表及說明\n" + 
			"kbot help [help/keyword]：查看特定指令"
		str_alert = "==========================\n" + 
			"備註：本指令系統有提供縮寫：\n" + 
			"help <=> h\n" + 
			"keyword <=> kw\n" + 
			"[new/remove/list] <=> [n/r/l]"

		if selection.nil?
			str_output = str_title + "\n" + str_help + "\n" + str_kw + "\n" + str_alert
		else
			if selection =~ /^help|h\b/
				str_output = "kbot help 指令列表：" + "\n" + str_help + "\n" + str_alert
			elsif selection =~ /^keyword|kw\b/
				str_output = "kbot keyword 指令列表：" + "\n" + str_kw + "\n" + str_alert
			else
				str_output = "無此指令"
			end
		end

		return str_output
	end

	def keyword_trigger(channel_id, received_text)
	    # keyword相關指令-----------------------------------
	    def keyword_new(channel_id, keyword , message)
			KeywordMapping.create(channel_id: channel_id, keyword: keyword, message: message)
			return "新增關鍵字：#{keyword}\n對應回覆：#{message}"
		end

		def keyword_remove(channel_id, received_text)
			data_count = KeywordMapping.where(channel_id: channel_id).count
			data_arr = KeywordMapping.where(channel_id: channel_id).first(data_count)
			if received_text == "/all"
				data_arr.each do |data|
					data.destroy
				end
				return "已清除全部關鍵字"
			end
			delete_data = data_arr[received_text.to_i - 1]
			delete_data.destroy
			return "刪除#{delete_data.keyword}及其對應回覆"
		end

		def keyword_list(channel_id)
			i = 1
			data_count = KeywordMapping.where(channel_id: channel_id).count
			str_return = "總資料筆數：#{data_count}\n\n"
			data_arr = KeywordMapping.where(channel_id: channel_id).first(data_count)
			data_arr.each do |data|
				str_return += "index: #{i}| #{data.keyword} <=> #{data.message}\n"
				i += 1
			end
			return str_return
		end

		# 主要處理區---------------------------------------
		dict_reg = {
			"n" => /^(new|n)\b\s+(\S+)\s+(\S+)/,
			"r" => /^(remove|r)\b\s+(\S+)/,
			"l" => /^(list|l)\b/
		}

		if received_text =~ dict_reg["n"]
			if !($2 == "" && $3 == "")
				return keyword_new(channel_id, $2, $3)
			else
				return "查無指令，使用kbot help或kbot h查看指令列表"
			end
		elsif received_text =~ dict_reg["r"]
			return keyword_remove(channel_id, $2)
		elsif received_text =~ dict_reg["l"]
			return keyword_list(channel_id)
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
