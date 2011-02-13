(Selenium) Page Objects in Ruby (RSpec)
=======================================

Page Objects 101
----------------

'Page Objects' is a pattern for creating Selenium scripts that makes heavy use of OO principles to enable code reuse and improve maintenance. Rather than having test methods that are a series of Se commands that are sent to the server, your scripts become a series of interactions with objects that represent a page (or part of one) -- thus the name.  

Without Page Objects
    def test_example
      @selenium.open "/"
      @selenium.click "css=div.account_mast a:first", :wait_for => :page
      @selenium.type "username", "monkey"
      @selenium.type "password", "buttress"
      @selenium.click "submit", :wait_for => :page
      assert_equal @selenium.get_text("css=div.error > p"), "Incorrect username or password."
    end

With Page Objects
    describe "Login" do
      context "invalid password" do
        it "prints error message" do
          @home = PageObjects::HomePage.new
          @login = @home.goto_login_form
          @login.username = "foo"
          @login.password = "bar"
          @login.login
          @login.error_message.should == "Incorrect username or password."
        end
      end

As you can see, not only is the script that uses POs [slightly] more human readable, but it is much more maintainable since it really does separate the page interface from the implementation so that _when_ something on the page changes only the POs themselves need to change and not ten billion scripts.  

Anatomy of a Ruby Page Object
-----------------------------

Page Objects have two parts
* Elements
* Actions

_Elements_

Elements in Ruby Page Objects are done by overriding the Page's getters and setters to interact with the browser. Here is how the above example types the password into the login form and how it retrieves the resulting error message

    def password=(password)
      @browser.type LOCATORS["password"], password
    end

    def error_message
      @browser.get_text LOCATORS["error_message"]
    end

_Actions_

Actions are the part of the page that does something, like submitting a form, or clicking a link. These are implemented as methods on the PO, for example, submitting the login form is implemented as such.

    def login
      @browser.click LOCATORS["submit_button"], :wait_for => :page
    end

so you can call it as thus.

    @login.login
    
One decision you have to make is whether to have actions that result in changing pages return the PO or not. I'm currently leaning towards that being a good thing.

Locators
--------

One of things POs help you with is isolating your locators since they are tucked away in a class rather than spread throughout your scripts. I _highly_ suggest that you go all the way and move your locators from in the actual Se calls to a constant in the class.

    LOCATORS = {
      "username" => "username",
      "password" => "password",
      "submit_button" => "submit",
      "error_message" => "css=div.error p:nth(0)"
    }

Now your locators truly are _change in one spot and fix all the broken-ness_. DRY code is good code. It is a code smell to rethink how you are slicing the page into object if you think you need to have the same locator in multiple classes.

Sharing the server connection
-----------------------------

It has been pointed out to me that what I have done to share the established connection/session to the Se server is borderline evil, but I understand it which trumps evil in my books. In order to make sure we can send / receive from the Se server from any PO, I make the connection to it a Singleton which gets set as a class a in the base PO. Most of the time your actual scripts won't need access to the actual browser connection (that's kinda the point of POs).

    module PageObjects
      class BasePage
        def initialize
          @browser = SeleniumHelpers::SeleniumConnection.instance.connection
        end
      end
    end

Apparently what I wanted was to use Dependency Injection but I only really understood it last weekend so this works -- if slightly evil.

Before / After
--------------

RSpec is an xUnit style framework which means it has methods that are called before and after each test method. Because we know that we want to start a browser before each run and close it afterwards we specify what we want via RSpec.configure.

    RSpec.configure { |c|
      c.before(:each) {
        @browser = SeleniumHelpers::SeleniumConnection.instance.connection
        @browser.start_new_browser_session
        @browser.window_maximize
        @browser.open("/")
      }

      c.after(:each) {
        @browser.close_current_browser_session
      }
    }

There is also :suite and :all available if there were things you wanted to do at those points as well.


TO-DO
-----
* config files
* tags
* ondemand
** basic
** tagging
** fetch video
** fetch logs
* logging
* random data
* data driving
* soft asserts (custom expectations)
* custom matchers
* custom exceptions