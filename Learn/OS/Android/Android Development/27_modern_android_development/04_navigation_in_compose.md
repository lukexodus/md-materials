## Navigation in Compose


Navigation in Compose applications is handled by the Navigation Compose library, which provides a declarative approach to navigation that integrates seamlessly with Compose's design principles.

**Basic Navigation Setup**

Navigation is built around a NavController and NavHost. The NavHost defines the navigation graph and handles the composable destinations.

```kotlin
@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    
    NavHost(
        navController = navController,
        startDestination = "home"
    ) {
        composable("home") {
            HomeScreen(
                onNavigateToProfile = {
                    navController.navigate("profile")
                }
            )
        }
        composable("profile") {
            ProfileScreen(
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
    }
}
```

**Passing Arguments**

Navigation supports passing arguments between destinations using route parameters and navigation arguments.

```kotlin
@Composable
fun AppNavigationWithArgs() {
    val navController = rememberNavController()
    
    NavHost(
        navController = navController,
        startDestination = "user_list"
    ) {
        composable("user_list") {
            UserListScreen(
                onUserClick = { userId ->
                    navController.navigate("user_detail/$userId")
                }
            )
        }
        composable(
            "user_detail/{userId}",
            arguments = listOf(navArgument("userId") { type = NavType.StringType })
        ) { backStackEntry ->
            val userId = backStackEntry.arguments?.getString("userId") ?: ""
            UserDetailScreen(
                userId = userId,
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}
```

**Nested Navigation**

Complex applications often require nested navigation graphs for features like bottom navigation or drawer navigation.

```kotlin
@Composable
fun MainScreen() {
    val navController = rememberNavController()
    
    Scaffold(
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    icon = { Icon(Icons.Default.Home, contentDescription = null) },
                    label = { Text("Home") },
                    selected = false,
                    onClick = { navController.navigate("home") }
                )
                NavigationBarItem(
                    icon = { Icon(Icons.Default.Person, contentDescription = null) },
                    label = { Text("Profile") },
                    selected = false,
                    onClick = { navController.navigate("profile") }
                )
            }
        }
    ) { paddingValues ->
        NavHost(
            navController = navController,
            startDestination = "home",
            modifier = Modifier.padding(paddingValues)
        ) {
            navigation(startDestination = "home_main", route = "home") {
                composable("home_main") { HomeMainScreen() }
                composable("home_settings") { HomeSettingsScreen() }
            }
            navigation(startDestination = "profile_main", route = "profile") {
                composable("profile_main") { ProfileMainScreen() }
                composable("profile_edit") { ProfileEditScreen() }
            }
        }
    }
}
```

