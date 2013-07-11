'use strict';

#
# A generic collection data type with ID awareness
#

angular.module('neo4jApp.services')
  .factory 'Collection', [
    () ->
      class Collection
        constructor: (items) ->
          @_reset()
          @add(items) if items?

        #
        # Instance methods
        #
        add: (items) ->
          itemsToAdd = if angular.isArray(items) then items else [items]
          for i in itemsToAdd
            if i.id?
              if not @_byId[i.id]
                @_byId[i.id] = i
                @items.push i
            else
              @items.push i
          return items

        all: ->
          @items

        first: ->
          @items.sort((a, b) -> a.id-b.id)[0]

        get: (id) ->
          return undefined unless id?
          id = parseInt(id, 10)
          return undefined if isNaN(id)
          @_byId[id]

        last: ->
          @items.sort((a, b) -> b.id-a.id)[0]


        reset: (items) ->
          @_reset()
          @add(items)

        pluck: (attr) ->
          return undefined unless angular.isString(attr)
          i[attr] for i in @items

        where: (attrs) ->
          rv = []
          return rv unless angular.isObject(attrs)

          numAttrs = Object.keys(attrs).length

          for item in @items
            matches = 0
            for key, val of attrs
              matches++ if item[key] is val

            rv.push item if numAttrs is matches

          rv

        #
        # Internal methods
        #

        _reset: ->
          @items = []
          @_byId = {}

      Collection
]
