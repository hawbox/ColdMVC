/**
 * @accessors true
 */
component {

	property beanFactory;

	public any function init() {
		cache = {};
		return this;
	}

	public any function autowire(required any object) {

		var i = "";

		// get the name of the component for caching purposes
		var classPath = getMetaData(object).name;

		// if the cache isn't already aware of the dependencies
		if (!structKeyExists(cache, classPath)) {

			// prevent race conditions
			lock name="coldmvc.app.util.BeanInjector_#classPath#" type="exclusive" timeout="5" throwontimeout="true" {

				// double-check just to be sure
				if (!structKeyExists(cache, classPath)) {
					cache[classPath] = findDependencies(object);
				}

			}
		}

		autowireBeans(object, classPath);

		return object;

	}

	private struct function findDependencies(required any object) {

		var dependencies = {};
		var i = "";
		var metaData = getMetaData(object);

		// conditionally loop while the object is being extended
		while (structKeyExists(metaData, "extends")) {

			// if the current object has functions
			if (structKeyExists(metaData, "functions")) {

				// loop over the functions
				for (i = 1; i <= arrayLen(metaData.functions); i++) {

					// get the function at the current index
					var method = metaData.functions[i];

					// if the method starts with "set"
					if (left(method.name, 3) == "set" && len(method.name) > 3) {

						// if access wasn't specified or it was set to public
						if (!structKeyExists(method, "access") || method.access == "public") {

							// get the property by replacing "set"
							var property = replaceNoCase(method.name, "set", "");

							// if the property hasn't been found yet
							if (!structKeyExists(dependencies, property)) {

								// if the property structKeyExists in the bean factory, get it
								if (beanFactory.containsBean(property)) {
									dependencies[property] = beanFactory.getBean(property);
								}

							}

						}

					}

				}

			}

			// recursion
			metaData = metaData.extends;
		}

		return dependencies;

	}

	private void function autowireBeans(required any object, required string classPath) {

		var beans = cache[classPath];
		var bean = "";

		for (bean in beans) {
			evaluate("object.set#bean#(beans[bean])");
		}

	}

}