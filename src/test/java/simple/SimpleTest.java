package simple;

public class SimpleTest {
    @BeforeClass
    public static void setUpBeforeClass() throws Exception {

        // Read in test files

    }

    @AfterClass
    public static void tearDownAfterClass() throws Exception {

        // Release test files
    }

    @Before
    public void setUp() throws Exception {
        // Method annotated with `@Before` will execute before each test method in this class is executed.

        // If you find that several tests need similar objects created before they can run this method could
        // be used to do set up those objects (aka test-fixtures).
    }

    @After
    public void tearDown() throws Exception {

        // Method annotated with `@After` will execute after each test method in this class is executed.

        // If you allocate external resources in a Before method you must release them in this method.
    }

    @Test
    public void test1() {

        // src/test/resources/simple/test01-example
    }

    @Test
    public void test2() {

        // src/test/resources/simple/test02-no-catalog
    }

    @Test
    public void test3() {

        // src/test/resources/simple/test03-multi-catalog
    }
}
