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
      @selenium.get_text("css=div.error > p").should == "Incorrect username or password."
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

There is also :suite and :all available if there were things you wanted to do at those points as well. Like, say, reading config files.

What is really cool about before/after is they can be nested inside layers of describe and context blocks and will execute from furthest out in.

    describe "foo" do
      before(:each) do
        p 'a'
      end
      describe "bar" do
        before 'a' do
          p 'a'
        end

Config Files
------------

The default config format for Ruby (thanks to the Rails kids) is YAML so we'll drive the config from there. So as alluded to above, the before(:all) is a nice way to load things.

    c.before(:all) {
      @config = SeleniumHelpers::Configuration.instance.config
    }

But wait, that's another singleton. Will the madness ever end? The reason for this is that Page Objects, scripts, helpers and oracles all need to be able to access the information tucked away in these configs. The first thing to be driven from a file is the initial server connection.

    def initialize
      @connection = Selenium::Client::Driver.new \
                      :host => SeleniumHelpers::Configuration.instance.config['selenium']['host'],
                      :port => SeleniumHelpers::Configuration.instance.config['selenium']['port'],
                      :browser => SeleniumHelpers::Configuration.instance.config['selenium']['browser'],
                      :url => SeleniumHelpers::Configuration.instance.config['selenium']['base_url'],
                      :timeout_in_second => SeleniumHelpers::Configuration.instance.config['selenium']['timeout']
    end
    
It's a lot to type, and pretty yucky looking, but you don't need to look at it very often.

Also notice that selenium.yml is not committed but selenium.yml.default is. This is me blatantly borrowing good ideas the from the RoR kids. As you'll see with the CI integration, it allows for easy parallel, cross-browser script execution without the need to get Se-Grid involved.

Tags
----

The selenium-webdriver gem is darn near idiomatically perfect for dealing with synchronization but I had a hard time recommending it to people as none of the Ruby test runners were able to handle test discovery via tags. But apparently RSpec grew this ability last July and the runner caught up in November.

Tags solve the venn diagram problem of where to put a script. Selenium scripts cross boundaries that 'unit' scripts don't have to worry about so we often find ourselves asking: Does it go with the admin persona scripts? Or the login ones? Or the smoke tests? Tags lets us not worry about this problem and apply the desired metadata to our scripts.

    context "correct password", :depth => 'shallow', :login => true do
      it "goes to account page"
    end

In this example there are two tags in play. The first is for the depth of the script. I tag everything as either 'deep' or 'shallow'. Shallow scripts are ones that are often called 'smoke' or 'sanity' scripts that but I couldn't figure out a nice opposite value. _shallow_ scripts _must_ pass in order to declare a build testable. To run the 'shallow' test you use

    --tag depth:shallow

The other tag really addresses the venn problem; I wouldn't worry about setting it to false if it isn't applicable -- just don't add it.

    --tag login

And you can have multiple tags when calling the runner too in order to narrow down what you are looking for.

    --tag depth:shallow --tag login
    
Synchronization
---------------

    One of the nice things about the Ruby drivers for Selenium is its idiomatically correct handling of synchronization using :wait_for after an event. Such as:

        se.click "a_locator", :wait_for => :page

    In general there are three different types os synchronization events.

    1. Web 1.0 - these events are ones where there is a a page or window reload as a result of an action in the browser.
        :wait_for => :page
        :wait_for => :popup, :window => 'a window id'

    2. Web 2.0 - with the rise of AJAX and related technologies we can no longer rely on the browser being reloaded. Now we need to be a bit more tricky about things looking at whether the content itself has changed.

    By default these have hooks for prototype; override this using :javascript_framework

        :wait_for => :ajax

    is the same as

        :wait_for => :ajax, :javascript_framework => :prototype

    :javascript_framework can also be set when you make the connection to the server so that you don't have to remember to type it every single time

        :wait_for => :ajax, :javascript_framework => :jquery
        :wait_for => :effects
        :wait_for => :effects, :javascript_framework => :jquery

    The rest of the Web 2.0 synchronization hooks deal with the page content directly. The first four are the ones most often used

        :wait_for => :element, :element => 'new_element_id'
        :wait_for => :no_element, :element => 'new_element_id'
        :wait_for => :visible, :element => 'a_locator'
        :wait_for => :not_visible, :element => 'a_locator'
        :wait_for => :text, :text => 'some text'
        :wait_for => :text, :text => /A Regexp/
        :wait_for => :text, :element => 'a_locator', :text => 'some text'
        :wait_for => :text, :element => 'a_locator', :text => /A Regexp/
        :wait_for => :no_text, :text => 'some text'
        :wait_for => :no_text, :text => /A Regexp/
        :wait_for => :no_text, :element => 'a_locator', :text => 'some text'
        :wait_for => :no_text, :element => 'a_locator', :text => /A Regexp/
        :wait_for => :value, :element => 'a_locator', :value => 'some value'
        :wait_for => :no_value, :element => 'a_locator', :value => 'some value'
        :wait_for => :visible, :element => 'a_locator'
        :wait_for => :not_visible, :element => 'a_locator'

    3. Web 3.0 - Some sites have just a ridiculous amount of background services being checked, AJAX messages sent back and forth, use Comet events so things like :ajax don't ever end. For this you need to use a (Latch)[FINDME].

        :wait_for => :condition, :javascript => 'latch condition'

    All :wait_for expressions can also have and explicit timeout (:timeout_in_seconds key). Otherwise the default driver timeout is used (30s). This value can also be set at server connection.

Expectations
------------

RSpec doesn't use the word _assert_; instead they prefer _expectation_. There are two basic ways of setting up an expectation in RSpec

    * should
    * should_not

Each of these will take either an RSpec _matcher_ or a Ruby expression. And through some tricky meta-programming, each of these is available on all objects.

Ruby expressions that evaluate for should or should_not are pretty easy to grasp and use the standard comparison operators. The exception here is != which RSpec does not support. This means

    foo.should != 'bar'

needs to be rewritten as

    foo.should_not == 'bar'

There is deep Ruby internal reasons for this, but it also just reads nicer. What would be even nicer is to do away with the == altogether and use a built-in matcher such as

* equal
* include
* respond_to
* raise error

Which would give us

    foo.should_not equal('bar')

Creating Se scripts will result in a lot of _should_ and _should_not_ expectations and very few of the others. Remember, RSpec was designed as a code-level BDD framework first so its features reflect its heritage.

Matcher Magic
-------------

One thing I like about Ruby that I wish Python would copy is its notion of predicates which are methods whose name ends in ? and return True or False. If you have a matcher that starts with be_ it will call the predicate function that makes up the rest of the matcher.

Imagine you had a 

    class Person
      def admin?
        if self.role == :admin
          True
        else
          False
        end
      end
    end

You could then do

    p.should_not be_admin

The same magic happens with matchers that start with have_ for functions that begin with has_.

Providers
---------

Test 'data' should not be embedded in your script. Doing so means that you have to edit your script whenever the data changes. To solve this particular problem we can use a number of different 'providers' of information.

1. _Static_ - A Static provider is one which will return a data that is contained in its own class definition. It is somewhat akin to putting the data right in the script except that when it changes, it is only this data file that needs to be edited.

    @user = {
      "username" => "flying",
      "password" => "monkey"
    }

2. _CSV_ - The next step from the Static provider is to feed the information from a CSV file. This data can be as simple as usernames and password (like this example) or as complicated as the most efficient pair-wise paths from something like (Hexawise)[http://hexawise.com].

One useful thing to do with CSV data is to return a random row rather than a specific one.

    def random_row
      @csv_content[rand(csv_content.size)]
    end

3. _Database_ - A powerful way of driving your scripts is to use the information that is in your application already. In some cases you can use the native ORM (such as ActiveRecord) but other times you need to go directly at the database.

    def random_username_and_password
      res = @dbh.query("select username, password from provider order by rand() limit 1")
      res.fetch_row
    end

Skipping Examples
-----------------

Unlike some frameworks, like Nose for Python, there is no way in RSpec to 'skip' an example, you can however make it as Pending programatically.

    if Time.new.strftime("%A") != "Monday"
      pending("except its not Monday")
    end

Continuous Integration
----------------------

I recommend that people use something like (Jenkins)[http://jenkins-ci.com] to run all their Se scripts, including ones that they might naturally us something like Se-Grid for.  But using Jenkins you can..
* easily, and visually, see what the current status for all the environments is
* integrate it into a Continuous Delivery process
* execute a single environment without having to change anything in the scripts or configs
* run environments you have machines for behind your firewall, and then other ones you can off load to the Sauce Labs OnDemand cloud

CI integration is almost always accomplished by the mythical 'JUnit' xml which is implemented everywhere but not documented anywhere. In order to get RSpec to output this, you need to install the ci_reporter gem. Once you have it on the system you have a couple options though I prefer to include it on the commandline so it is there when I want (in the CI environment) and not when I don't (when I'm creating new scripts).

    --require GEM_PATH/lib/ci/reporter/rake/rspec_loader --format CI::Reporter::RSpec
    
The reports that it produces will be in the specs/reports directory so you need to specify that dir in the CI job's config as the location. It is likely also a good idea to archive those as well

TO-DO
-----
* ondemand
 * basic
 * tagging
 * fetch video
 * fetch logs
* logging
* ci integration
* random data
* soft asserts (custom expectations)
* custom matchers
* custom exceptions