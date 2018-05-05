_ = require('underscore')
trim = require('string.prototype.trim')

txtid = require('./model.utils').txtid

_tx_string_to_object = (translation, index, arr, active)->
  # when no translation_list exists, we create a translation_list
  # from the translation strings.
  out =
    name: translation
    code: "t#{index+1}"
    order: index

  mtch = translation.match(/(.+)\((\w+)\)/) if translation
  if mtch
    out.name = trim(mtch[1])
    out.code = mtch[2]

  if active
    out.active = true

  out

set_tx_id = (translation_object)->
  if not ('$uid' of translation_object)
    translation_object['$uid'] = txtid()
  translation_object

add_translation_list = (content)->
  if content.translations and not content.translation_list
    _tl = content.translations.map (translation_name, index)->
      _tx_string_to_object(translation_name, index, null, index is 0)
    content.translation_list = _tl
    delete content.translations
  else if not content.translation_list
    content.translation_list = [{name: null, active: true, order: 0}]
  _active = _.find content.translation_list, (tl)-> tl.active
  if not _active
    content.translation_list[0].active = true
  content

_change_order_by_attr = (attr_name)->
  (list, val)->
    _changed = false
    for item in list
      if item[attr_name] is val
        item.order = -1
        _changed = true
        break
    if not _changed
      throw new Error("Translation with #{attr_name}: #{val} not found")
    for item, index in _.sortBy(list, 'order')
      item.order = index

rename_first_translation_to_null = (list)->
  for item in list
    # if 'order' not of item
    #   throw new Error('translation order must be set')
    if item.order is 0
      if not item.savename
        item.savename = item.name
        item.name = null
    else
      if item.name is null
        item.name = item.savename or 'NOT_NAMED'
        item.savename = null

module.exports = {
  add_translation_list: add_translation_list
  set_tx_id: set_tx_id
  _tx_string_to_object: _tx_string_to_object
  rename_first_translation_to_null: rename_first_translation_to_null
  change_order_by_name: _change_order_by_attr('name')
  change_order_by_code: _change_order_by_attr('code')
}