# IrusAnalytics

IrusAnalytics is a gem that provides a simple way to send analytics to the IRUS-UK repository aggregation service.  

More information about IRUS-UK can be found at [http://www.irus.mimas.ac.uk/](http://www.irus.mimas.ac.uk/). In summary the IRUS-UK service is designed to provide article-level usage statistics, both for Investigations (views) and Requests (downloads), for Institutional Repositories.  To sign up and use IRUS-UK, please see the above link. 

This gem was developed for use with a Hyrax repository [http://samvera.org/](http://samvera.org/), but it can be used with any other web application supporting Ruby gems. 

More information on COUNTER reports and reporting can be found at [Project COUNTER](https://www.projectcounter.org/)

## Build Status
![Build Status](https://api.travis-ci.org/uohull/irus_analytics.png?branch=master)
## Prerequisite

[Blacklight OAI Provider](https://github.com/projectblacklight/blacklight_oai_provider) or some other method of displaying an OAI feed of your works or digital objects. While the irus_analytics gem will push limited usage data to IRUS-UK, they still need a way to harvest your repository metadata (like Title, Author, etc) to create COUNTER usage reports.

## Installation

Add this line to your rails application Gemfile:

    gem 'irus_analytics', git: 'https://github.com/mlibrary/irus_analytics'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install irus_analytics

## Usage

Once you have the gem, run the following generator:

    $ bundle exec rails generate irus_analytics:config

Or:

    $ rails g irus_analytics:config

This will generate editable configuration and translation files in the config folder.

### config/irus_analytics_config.yml

This uses a similar mechanism to the standard rails database.yml file to allow for per-environment configuration of the values for:

**source_repository**\
 is used to configure the name of the source respository url (i.e. what the url for your repository)

**irus_server_address**\
 is used to define the IRUS-UK server endpoint, this can be configured for the test version of the service.

**robots_file**\
is used to specify the name of the file containing the robot UserAgents as regular expressions.  

**Example installed file**

<pre>
development:
  enabled: true
  enable_send_logger: true
  irus_server_address: https://irus.jisc.ac.uk/counter/test/
  robots_file: irus_analytics_counter_robot_list.txt
  source_repository: localhost
  verbose_debug: true
test:
  enabled: true
  enable_send_logger: false
  irus_server_address: https://irus.jisc.ac.uk/counter/test/
  robots_file: irus_analytics_counter_robot_list.txt
  source_repository: production
  verbose_debug: false
production:
  enabled: true
  enable_send_logger: false
  irus_server_address: https://irus.jisc.ac.uk/counter/test/
  robots_file: irus_analytics_counter_robot_list.txt
  source_repository: production
  verbose_debug: false
</pre>

**Add named server section**

<pre>
production:
  enabled: true
  enable_send_investigations: true
  enable_send_logger: true
  enable_send_requests: true
  irus_server_address: https://irus.jisc.ac.uk/counter/test/
  robots_file: irus_analytics_counter_robot_list.txt
  source_repository: deepblue.lib.umich.edu/data
  verbose_debug: true
  named_servers: true
  deepblue.local:
    source_repository: localhost.deepblue.lib.umich.edu/data
  staging.deepblue.lib.umich.edu:
    source_repository: testing.deepblue.lib.umich.edu/data
  testing.deepblue.lib.umich.edu:
    source_repository: testing.deepblue.lib.umich.edu/data
</pre>


### Integration
The IrusAnalytics code is designed to be called after an Investigation (view) or Request (download) event has happened in your application. The following code added to the Rails controller handles the content download.

To add request handling to a controller, run the following:

Note: options are sent as single string, space separated options, option_name:value

`type:investigation` or `type:request`

`after_action:show`

`controller_class_name:Hyrax::DissertationsController`

**Inject Request controller hooks (test mode)**
<pre>
bundle exec rails generate irus_analytics:inject_controller_hooks "type:request after_action:zip_download controller_class_name:Hyrax::DissertationsController test_mode:true"
</pre>

**Inject Investigation controller hooks (test mode)**
<pre>
bundle exec rails generate irus_analytics:inject_controller_hooks "type:investigation after_action:show controller_class_name:Hyrax::DissertationsController test_mode:true"
</pre>


**Inject Request controller hooks**
<pre>
bundle exec rails generate irus_analytics:inject_controller_hooks "type:request after_action:zip_download controller_class_name:Hyrax::DissertationsController"
</pre>

**Inject Investigation controller hooks**
<pre>
bundle exec rails generate irus_analytics:inject_controller_hooks "type:investigation after_action:show controller_class_name:Hyrax::DissertationsController"
</pre>

A simple example of before and after of running both Investigation and Request generators against `Hyrax::DissertationsController`:

**Before**

<pre>
# frozen_string_literal: true

module Hyrax
  # Generated controller for Dissertation
  class DissertationsController < DeepblueController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    #include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Dissertation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DissertationPresenter
  end
end
</pre>

**After**

<pre>
# frozen_string_literal: true

module Hyrax
  # Generated controller for Dissertation
  class DissertationsController < DeepblueController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: include IrusAnalytics controller behavior
    include IrusAnalytics::Controller::AnalyticsBehaviour
    # end inject IrusAnalytics::InjectControllerHooksGenerator: include IrusAnalytics controller behavior
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: IrusAnalytics after action
    after_action :send_irus_analytics_request, only: [:zip_download]
    # end inject IrusAnalytics::InjectControllerHooksGenerator: IrusAnalytics after action
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: IrusAnalytics after action
    after_action :send_irus_analytics_investigation, only: [:show]
    # end inject IrusAnalytics::InjectControllerHooksGenerator: IrusAnalytics after action

  public
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: item_identifier_for_irus_analytics
    def item_identifier_for_irus_analytics
      # return the OAI identifier
      # http://www.openarchives.org/OAI/2.0/guidelines-oai-identifier.htm
      CatalogController.blacklight_config.oai[:provider][:record_prefix] + ":" + params[:id]
    end
    # end inject IrusAnalytics::InjectControllerHooksGenerator: item_identifier_for_irus_analytics
    # begin inject IrusAnalytics::InjectControllerHooksGenerator: skip_send_irus_analytics?
    def skip_send_irus_analytics?(usage_event_type)
      # return true to skip tracking, for example to skip curation_concerns.visibility == 'private'
      case usage_event_type
      when 'Investigation'
        false
      when 'Request'
        false
      end
    end
    # end inject IrusAnalytics::InjectControllerHooksGenerator: skip_send_irus_analytics?


    #include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Dissertation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DissertationPresenter
  end
end
</pre>


## In Summary (to do)

Therefore in summary...

    include IrusAnalytics::Controller::AnalyticsBehaviour  
  
    after_filter :send_analytics, only: [:show]

    def item_identifier_for_irus_analytics
      CatalogController.blacklight_config.oai[:provider][:record_prefix] + ":" + params[:id]
    end

... needs adding to the relevant controller.

NOTE: If you are not using the [Blacklight OAI Provider](https://github.com/projectblacklight/blacklight_oai_provider) gem to create your OAI feed, you'll need to modify the `item_identifier_for_irus_analytics` method to conform with your application's [OAI identifiers](http://www.openarchives.org/OAI/2.0/guidelines-oai-identifier.htm).

To be compliant with the IRUS-UK client requirements/recommendations this Gem makes use of the Resque  [https://github.com/resque/resque](https://github.com/resque/resque).  Resque provides a simple way to create background jobs within your Ruby application, and is specifically used within this gem to push the analytics posts onto a queue.  This means the download functionality within your application is unaffected by the send analytics call, and it provides a means of queuing analytics if the IRUS-UK server is down. 

Note: Resque requires Redis to be installed  

By installing this gem, your application should have access to the Resque rake tasks.  These can be seen by running "rake -T",  the list should include:-

    rake resque:failures:sort 
    rake resque:work
    rake resque:workers

To start the resque background job for this gem use

    QUEUE=irus_analytics rake environment resque:work

## Additional Notes for Hyrax

In a Hyrax application, the `Hyrax::DownloadsController` and `Hyrax::FileSetsController` will be in the Hyrax gem itself so the irus_analytics generator will not write to them. One can copy the entirety of these classes (and relevent specs) into one's application or can use the Module#Prepend pattern to add/modify the neccessary methods. An example for how to do this in Hyrax for a Presenter (but the idea is the same for Controllers) is here, https://samvera.github.io/patterns-presenters.html#overriding-and-custom-presenter-methods, or try something like:

```
# app/controllers/concerns/download_override.rb (or whatever convention you use)

Hyrax::DownloadsController.class_eval do
  prepend(DownloadsControllerBehavior = Module.new do
    include IrusAnalytics::Controller::AnalyticsBehaviour

    # Render the 404 page if the file doesn't exist.
    # Otherwise renders the file.
    def show
      case file
      when ActiveFedora::File
        # For original files that are stored in fedora
        send_irus_analytics_request
        super
      when String
        # For derivatives stored on the local file system
        send_local_content
      else
        raise Hyrax::ObjectNotFoundError
      end
    end

    def item_identifier_for_irus_analytics
      # return the OAI identifier
      CatalogController.blacklight_config.oai[:provider][:record_prefix] + ":" + FileSet.find(params[:id]).parent.id
    end
  end
end
```

where we add the `item_identifier_for_irus_analytics` method which reports the parent's or work's OAI identifier and we explicitly call the `send_irus_analytics_request` method only for Fedora downloads, not for derivatives like thumbnails since those are explicitly not considered Requests per COUNTER.

And then in application.rb something like:

```
config.to_prepare do
  # ensure overrides are loaded
  # see https://bibwild.wordpress.com/2016/12/27/a-class_eval-monkey-patching-pattern-with-prepend/
  Rails.configuration.cache_classes ? require("app/controllers/concerns/download_override.rb") : load("app/controllers/concerns/download_override.rb")
end
```

## Contributing

1. Fork it ( https://github.com/uohull/irus_analytics/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
