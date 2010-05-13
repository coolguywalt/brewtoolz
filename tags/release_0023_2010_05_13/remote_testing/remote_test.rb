# To change this template, choose Tools | Templates
# and open the template in the editor.

#Note requires jruby and celerity libraries to execute.


require "rubygems"
require "celerity"


$PASSWORD_PREFIX = "g0bst^fF3rs"
# $WEBSITE = 'http://brewtool.brwetoolz.com'
$WEBSITE = 'http://preprod.brewtoolz.com'
def random_browsing(browser, user)
	#Create new thread.

	#home_page
	home_page( browser )

	#login
	login(browser,user)

	#recipes
    recipes( browser )

	#create_recipe
	recipe_name =  "zz Test - #{user}" + Time.now.to_s
	create_and_edit_recipe( browser, recipe_name)

	#edit_recipe

	#create_log

	#brewday stuff

	#add observations

	#delete observations

	#add tastings

	#browse recipes
end

def home_page(browser)
	puts "Browse to home page:"
    browser.goto($WEBSITE)
    browser.link(:text, "Recipes").click
    puts "Found home page" if browser.text.include? 'Recent'
end

def login( browser, user )
	puts "Login user #{user}:"

	browser.link(:text, "Log in").click

    browser.text_field(:id, "login").value = user
    browser.text_field(:id, "password").value = $PASSWORD_PREFIX + user.to_s

	browser.button(:text, "Log in").click
end

def recipes( browser )
	puts "Browse to recipes list:"

	browser.link(:text, "Recipes").click

	puts "Found recipe page" if browser.text.include? 'Top rating Recipes'

end

def create_recipe_and_edit( browser, name )
	recipes( browser )

	puts "Creating recipe: #{name}"
	browser.link(:text, "New Recipe").click

	browser.text_field(:id, "recipe[name]").value = name

	browser.button(:text, "Create Recipe").click

	puts "Created recipe: #{name}"

	puts "Editing recipe"

	browser.link(:text, "Add").click # Add the first fermentable

    browser.span(:id, "og_show").click
	browser.text_field(:id, "og").value = '45.0'
	browser.button(:text, "Ok").click
end


def random_anon_browsing( browser )

	sleep(10 + rand(20))

	#home_page
	home_page( browser )

	sleep(8 + rand(10))

	#recipes
    recipes( browser )

end

def random_anon_browsers(num)

	count = 0
    threads = []
    num.times do |i|
		threads[i] = Thread.new do
	    abrowser = Celerity::Browser.new

		10.times do |i|
		  puts "Iterantion no: #{i}"
	      random_anon_browsing( abrowser )
		end

		end
    end
	threads.each {|t| t.join  }
end

#create 10 browser sessions and randomly look up activities
#random_anon_browsers( 10 )

no_browsers = 5
no_browsers = ARGV[0].to_i if ARGV.size > 0

#browser = Celerity::Browser.new
random_anon_browsers( no_browsers )

#home_page( browser )

#login( browser, "test1")

#recipes( browser )

#create_recipe_and_edit( browser, "zz Stinky brown one again")

#browser.link(:text, "Hank").click
#puts "double yay" if browser.text.include? 'Hank'
#
#browser.link(:text, "May 16, 2009").click
#puts "triple yay" if browser.text.include? 'Hank'
#
#browser.link(:text, "Log in").click
#browser.text_field(:id, "login").value = "chris"
#browser.text_field(:id, "password").value = "been2ITboyz"
#
#browser.button(:text, "Log in").click
#
#browser.goto('http://preprod.brewtoolz.com')
#puts "yay whoop" if browser.text.include? "Brewer's"
