One bad item in a wire delivery stops the whole import. An item whose
`filed_at` can't be read, or one without a `headline` field, raises; the job
fails and the good items after it never come in. Skip bad items of any kind
instead and count them as failed, like the items that fail validation (an
empty headline) are counted already.

Every failed item, including the ones that fail validation, should reach our
error tracker with the item's guid, so the desk can chase the agency. At the
moment none of them do.
