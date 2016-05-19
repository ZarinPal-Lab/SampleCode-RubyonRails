![](http://tecorb.com/wp-content/uploads/2015/06/ror.png)
![](http://xemeston.ir/wp-content/uploads/2016/05/zarinpal-logo.png)

# روبی آن ریلز :: درگاه پرداخت زرین پال

در گام اول شما باید جم مورد نظر را روی ریلز نصب کنید

## نصب جم از طریق جم فایل

Gemfile دستور زیر را کپی کنید و در فایل
اضافه کنید

    gem 'savon'

و سپس درستور زیر را در کامند لاین بزنید

    $ bundle install

## نصب جم از طریق کامند لاین

برای نصب جم میتوانید از طریق زیر هم عمل کنید
دستور زیر را در کامند لاین اجرا کنید

    $ gem install savon

### ساختن کنترولر زرین پال در ریلز

برای ایجاد کنترولر در ریلز درستور زیر را در کمند لاین اجرا کنید

    rails generate controller zarinpal
    
سپس فایل زیر را باز کنید

    app/controllers/zarinpal_controller.rb
    
متن زیر را جایگزینه کنید

```ruby
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
					"MerchantID" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", # ای پی آی درگاه زرین پال شما
					"Amount" => params['amount'], # مبلغ پرداختی
					"Description" => "توضیحات درگاه",
					"Email" => "ایمیل کاربر",
					"Mobile" => "شماره تماس کاربر",
					"CallbackURL" => "http://localhost:3000/zarinpal/verify" # صفحه بازگشت از درگاه
				})
				results = response.body
				authority = results[:payment_request_response][:authority]
				status = results[:payment_request_response][:status]
				if status.to_i < 100
					render :text => "Some Thing's wrrong"
				else 
					session[:AMOUNT] = params['amount'] # ذخیره ی موقف مبلغ در سشن
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
				"MerchantID" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", # ای پی آی درگاه زرین پال شما
				"Amount" => session[:AMOUNT], # مبلغ پرداختی که در سشن قرارداده شده بود
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
```

### ویرایش کنترولر برای وصل شدن به درگاه

`کلمات کلیدی زیر شمارا به درگاه زرین پال متصل میکند`

```ruby
	MerchantID => آی پی آی گرفته شده از زرین پال
	params['amount'] => مبلغ پرداختی که باید بصورت پست ارسال شود
	params['email'] => ایمیل کاربر
	params['description'] => توضیحات پرداخت
	params['mobile'] => تلفن همراه کاربر
```

## تست درگاه
صفحه ی درگاه را در مرورگر باز کنید

	Address : http://localhost:3000/zarinpal/
	
![](http://uploadbot.ir/files/form.jpg)
	
سپس مبلغ را وارد کنید

	مثال : 10000
	
سسپس دکمه ی پرداخت را فشار دهید

![](http://uploadbot.ir/files/zarin.jpg)

اگر چنین صفحه ای مشاهده میکنید شما با موفقت به درگاه متصل شده اید 
لذت ببرید 🤗
