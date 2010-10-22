/**
 * @accessors true
 * @action list
 * @extends coldmvc.Controller
 */
component {

	function list() {

		var paging = $.paging.options();

		var options = {
			sort = "firstName",
			order = "asc",
			max = paging.max,
			offset = paging.offset
		};

		var search = $.params.get("search");

		if (search != "") {
			params.users = _User.findAllByFirstNameLikeOrLastNameLikeOrEmailLike(search, search, search, options);
			params.count = _User.countByFirstNameLikeOrLastNameLikeOrEmailLike(search, search, search);
		}
		else {
			params.users = _User.list(options);
			params.count = _User.count();
		}

	}

	function save() {

		var user = _User.get(params.user.id, params.user);
		user.save();

		flash.message = "User saved successfully";
		redirect({action="edit", id=user});

	}

}