# Radiant Facebook Extension

Access the Facebook OpenGraph API via Radiant CMS.

This extension assumes you know what the API and response data looks like and lets you query any field you need by using <r:data /> to access the response hash directly and <r:each /> to iterate over arrays.

If you want an idea of what the response data looks like start up IRB and try:

    require 'rest-graph'
    require 'yaml'
    rg = RestGraph.new
    puts rg.get('/google/feed')['data'].to_yaml

## Installation

    gem install rest-graph
    git submodule add git://github.com/nuex/radiant-facebook-extension vendor/extensions/facebook

## Usage

    <r:facebook get="/google/feed">
      <r:each key="data">
        <div class="feed-item">
          <div class="icon">
            <img src="<r:data key="icon" />" alt="" />
          </div>
          <div class="content">
            <p class="message">
              <r:data key="message" />
            </p>
            <r:if_data key="link">
              <p class="link"><a href="<r:data key="link""><r:data key="link" /></a></p>
            </r:if_data>
            <div class="created_at">
              <r:data key="created_time" type="time" format="%m/%d/%Y" />
            </div>
          </div>
        </div>
      </r:each>
    </r:facebook>
