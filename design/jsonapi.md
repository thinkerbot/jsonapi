# jsonapi

Tool to fetch and select resources via JSON API.  Maintains a session with login information as needed.

## Usage

  # get uri, put all resources into cache
  get uri                 # => [{data resources}]   (updates curr_doc)
  select selector         # => [{select resources}] (updates curr)

  default :get, selector  # sets default post-GET selector
  get uri                 # => [{select resources}]

  # same for other methods
  default :put, selector  # sets default post-PUT selector
  put uri, {}             # => [{data resources}] (updates curr_doc)
  post uri, {}            # => [{data resources}] (updates curr_doc) 
  patch uri, {}           # => [{data resources}] (updates curr_doc)  
  delete uri              # => [{data resources}] (updates curr_doc) 

  # settings
  default :all, selector            # sets default selector for all methods
  default [:put, :post], selector   # sets default selector for specified methods

  # remove uri resources from cache
  clear uri
  # remove all uri, clear cache
  cache

  # mirror methods that do not update curr_doc, but they do update cache
  _get uri                # => [{data resources}]
  _put uri, {}            # => [{data resources}]
  _post uri, {}           # => [{data resources}]
  _patch uri, {}          # => [{data resources}]
  _delete uri             # => [{data resources}]

  curr_doc                # => doc
  docs                    # => {uri => doc}
  cache                   # => {type => {id => resource}}

  curr                    # => [{select resources}]
  curr.each {|resource| ... }
  curr.each(&:put)        # curr.each {request to resource.self with resource}
  curr.each(&:post)       # curr.each {request to resource.self with resource}
  curr.each(&:patch)      # curr.each {request to resource.self with resource}
  curr.each(&:delete)     # curr.each {request to resource.self with resource}

  curr.first.put
  curr[0,2].each(&:post)

The key idea is that a response document is a set of resources.  The selectors pick resources, or subsets of resources out of a current document.  The selectors have defaults associated with the current document (ie when type is omitted at the head) but can select from anywhere in the cache.  The selections are outputs as well as handles for future actions.  They are disposable.  Selections automatically make fetch resources as needed.  Requests are logged to a logger.

## Selectors

    type["id"]     # pick from cache by type, id
    type[*]        # pick all ids (follows pagination to completion)
    type[i]        # pick id at index i in current resource (follows pagination as needed)
    type[i,n]      # pick slice in current resource (follows pagination as needed)

    type:id        # shorthand for type["id"] for simple ids
    type           # shorthand for type[*]

    SELECTOR|SELECTOR   # address is a chain of selectors
    ADDR,ADDR ...       # pick multiple from cache

The first addr can omit type in which case the type of the current document data will be used.  In the first round do something like:

* ignore multiple addresses
* ignore type["id"], type[*]

Then:

    selectors = address.split("|")
    selectors.inject(curr_set) do |curr, selector|
      case selector
      when /^(.*):(.*)$/    # type:id
      when /^(.*)[(.*)]$/   # type[i], type[i,n]
      else # type
      end

      # resolve and wrap selections...
    end
    
A full grammer and crap like that would be needed to do things properly because the `type["id"]` would prohibit simple splitting on ',' and '|'.  Moreover something would be needed to handle types that could have arbitrary characters in them... so the fundamental might be `"type"["id"]` (yuck!).  Although... I guess you could look at this as CSV '|' within CSV ',' and then a match on the individual selectors... anyhow icky either way.

## Internal Structure

  class Session
    cache
    _get             # makes request, wraps in appropriate document class
    get              # _get plus populates cache from document.linked and pushes onto stack
  end

  class Resource (abstract)
    attrs
    links
    meta
    url # links["self"]

    session           # used to make requests, and to access session cache
    select(selector)  # resolves link objects, follows pagination, looks up in cache as needed (via session)
  end

  class Document < Resource
    linked            # wraps as ResourceObject referenced back to self
    compound?
  end

  class DataDocument < Document
    data              # wraps as ResourceObject referenced back to self
  end

  class ErrorDocument < Document
    errors            # wraps as ErrorObject referenced back to self
  end

  class ResourceObject < Resource
    id
    type
    document
  end

  class LinkObject
    url
    resource
    data         # could be expressed as: type+id or type+ids
    meta
  end

  class ErrorObject
    id
    href
    status
    code
    title
    detail
    links
    paths
  end



