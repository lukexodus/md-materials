## Activity Navigation Patterns


Modern Android navigation follows established patterns that provide consistent user experiences and maintainable code structures.

### Hierarchical Navigation

```kotlin
class HierarchicalNavigation {
    
    // Parent-child relationship navigation
    class ParentActivity : AppCompatActivity() {
        
        private fun navigateToChild() {
            val intent = Intent(this, ChildActivity::class.java)
            intent.putExtra("parent_data", "Data from parent")
            startActivity(intent)
        }
    }
    
    class ChildActivity : AppCompatActivity() {
        
        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            
            // Enable up navigation
            supportActionBar?.setDisplayHomeAsUpEnabled(true)
        }
        
        override fun onSupportNavigateUp(): Boolean {
            // Handle up navigation with data
            val resultIntent = Intent().apply {
                putExtra("result_data", "Data from child")
            }
            setResult(RESULT_OK, resultIntent)
            finish()
            return true
        }
        
        override fun onOptionsItemSelected(item: MenuItem): Boolean {
            return when (item.itemId) {
                android.R.id.home -> {
                    onSupportNavigateUp()
                }
                else -> super.onOptionsItemSelected(item)
            }
        }
    }
}
```

### Tab-Based Navigation

```kotlin
class TabNavigationActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_tab_navigation)
        
        setupTabLayout()
    }
    
    private fun setupTabLayout() {
        val viewPager = findViewById<ViewPager2>(R.id.viewPager)
        val tabLayout = findViewById<TabLayout>(R.id.tabLayout)
        
        val adapter = TabPagerAdapter(this)
        viewPager.adapter = adapter
        
        TabLayoutMediator(tabLayout, viewPager) { tab, position ->
            tab.text = getTabTitle(position)
        }.attach()
    }
    
    private fun getTabTitle(position: Int): String {
        return when (position) {
            0 -> "Home"
            1 -> "Search"
            2 -> "Profile"
            else -> "Tab $position"
        }
    }
}

class TabPagerAdapter(fragmentActivity: FragmentActivity) : FragmentStateAdapter(fragmentActivity) {
    
    override fun getItemCount(): Int = 3
    
    override fun createFragment(position: Int): Fragment {
        return when (position) {
            0 -> HomeFragment()
            1 -> SearchFragment()
            2 -> ProfileFragment()
            else -> Fragment()
        }
    }
}
```

### Drawer Navigation

```kotlin
class DrawerNavigationActivity : AppCompatActivity() {
    
    private lateinit var drawerLayout: DrawerLayout
    private lateinit var actionBarDrawerToggle: ActionBarDrawerToggle
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_drawer_navigation)
        
        setupDrawer()
        setupNavigationView()
    }
    
    private fun setupDrawer() {
        drawerLayout = findViewById(R.id.drawer_layout)
        actionBarDrawerToggle = ActionBarDrawerToggle(
            this,
            drawerLayout,
            R.string.drawer_open,
            R.string.drawer_close
        )
        
        drawerLayout.addDrawerListener(actionBarDrawerToggle)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
    }
    
    private fun setupNavigationView() {
        val navigationView = findViewById<NavigationView>(R.id.nav_view)
        navigationView.setNavigationItemSelectedListener { menuItem ->
            when (menuItem.itemId) {
                R.id.nav_home -> navigateToSection("home")
                R.id.nav_settings -> navigateToSection("settings")
                R.id.nav_about -> navigateToSection("about")
            }
            drawerLayout.closeDrawer(GravityCompat.START)
            true
        }
    }
    
    private fun navigateToSection(section: String) {
        val intent = when (section) {
            "home" -> Intent(this, HomeActivity::class.java)
            "settings" -> Intent(this, SettingsActivity::class.java)
            "about" -> Intent(this, AboutActivity::class.java)
            else -> return
        }
        startActivity(intent)
    }
    
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (actionBarDrawerToggle.onOptionsItemSelected(item)) {
            return true
        }
        return super.onOptionsItemSelected(item)
    }
}
```

### Bottom Navigation

```kotlin
class BottomNavigationActivity : AppCompatActivity() {
    
    private lateinit var bottomNavigation: BottomNavigationView
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_bottom_navigation)
        
        setupBottomNavigation()
    }
    
    private fun setupBottomNavigation() {
        bottomNavigation = findViewById(R.id.bottom_navigation)
        bottomNavigation.setOnItemSelectedListener { item ->
            when (item.itemId) {
                R.id.nav_home -> {
                    replaceFragment(HomeFragment())
                    true
                }
                R.id.nav_search -> {
                    replaceFragment(SearchFragment())
                    true
                }
                R.id.nav_favorites -> {
                    replaceFragment(FavoritesFragment())
                    true
                }
                R.id.nav_profile -> {
                    replaceFragment(ProfileFragment())
                    true
                }
                else -> false
            }
        }
        
        // Set default selection
        bottomNavigation.selectedItemId = R.id.nav_home
    }
    
    private fun replaceFragment(fragment: Fragment) {
        supportFragmentManager.beginTransaction()
            .replace(R.id.fragment_container, fragment)
            .commit()
    }
}
```

