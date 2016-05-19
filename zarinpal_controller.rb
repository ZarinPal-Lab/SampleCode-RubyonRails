class ZarinpalController < ActionController::Base
	# Author : Alireza Josheghani #
	# WebSite : http://lemax.ir #
	# Version : 1.0 For ZarinPal #
	def pay
		if !params['amount'].blank?
			if params['amount'].to_i > 99
				client = Savon.client(
					wsdl: "https://de.zarinpal.com/pg/services/WebGate/wsdl")
				response = client.call(:payment_request, message: {
					"MerchantID" => "50966498-0ec6-11e6-9695-005056a205be",
					"Amount" => params['amount'],
					"Description" => "توضیحات درگاه",
					"Email" => "ایمیل کاربر",
					"Mobile" => "شماره تماس کاربر",
					"CallbackURL" => "http://localhost:3000/zarinpal/verify"
				})
				results = response.body
				authority = results[:payment_request_response][:authority]
				status = results[:payment_request_response][:status]
				if status.to_i < 100
					render :text => "Some Thing's wrrong"
				else 
					session[:AMOUNT] = params['amount']
					redirect_to "https://www.zarinpal.com/pg/StartPay/#{authority}"
				end
			else
				render :text => "مبلغ نا معتبر است"
			end
		else
			render :text => "مبلغ را وارد کنید"
		end
	end
	def verify
		if !params['Authority'].blank?
			client = Savon.client(wsdl: "https://de.zarinpal.com/pg/services/WebGate/wsdl")
			response = client.call(:payment_verification, message: {
				"MerchantID" => "50966498-0ec6-11e6-9695-005056a205be",
				"Amount" => session[:AMOUNT],
				"Authority" => params['Authority']
			})
			session.delete(:AMOUNT)
			results = response.body
			status = results[:payment_verification_response][:status]
			ref_id = results[:payment_verification_response][:ref_id]
			if status.to_i < 100
				render :text => "تراکنش از طرف کاربر متوقف شد"
			else 
				render :text => "تراکنش با موفقیت انجام شد . کد پیگیری : #{ref_id}"
			end
		else
			redirect_to "http://localhost:3000/zarinpal/"
		end
	end
end
