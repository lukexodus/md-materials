## NFC Implementation


Near Field Communication (NFC) enables short-range communication for contactless payments, data exchange, and device pairing.

### NFC Setup and Detection

**Manifest Configuration:**

```xml
<uses-permission android:name="android.permission.NFC" />
<uses-feature 
    android:name="android.hardware.nfc" 
    android:required="true" />

<activity android:name=".NFCActivity">
    <intent-filter>
        <action android:name="android.nfc.action.NDEF_DISCOVERED" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="text/plain" />
    </intent-filter>
    
    <intent-filter>
        <action android:name="android.nfc.action.TAG_DISCOVERED" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
    
    <intent-filter>
        <action android:name="android.nfc.action.TECH_DISCOVERED" />
        <category android:name="android.intent.category.DEFAULT" />
        <meta-data 
            android:name="android.nfc.action.TECH_DISCOVERED"
            android:resource="@xml/nfc_tech_filter" />
    </intent-filter>
</activity>
```

**NFC Manager Implementation:**

```kotlin
class NFCManager(private val activity: Activity) {
    private var nfcAdapter: NfcAdapter? = null
    private var pendingIntent: PendingIntent? = null
    private var intentFiltersArray: Array<IntentFilter>? = null
    private var techListsArray: Array<Array<String>>? = null
    
    init {
        nfcAdapter = NfcAdapter.getDefaultAdapter(activity)
        setupNFC()
    }
    
    private fun setupNFC() {
        // Create pending intent for NFC discovery
        val intent = Intent(activity, activity.javaClass).apply {
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        pendingIntent = PendingIntent.getActivity(
            activity, 0, intent, 
            PendingIntent.FLAG_MUTABLE
        )
        
        // Create intent filters
        val ndefFilter = IntentFilter(NfcAdapter.ACTION_NDEF_DISCOVERED).apply {
            try {
                addDataType("text/plain")
            } catch (e: IntentFilter.MalformedMimeTypeException) {
                throw RuntimeException("Failed to add MIME type.", e)
            }
        }
        
        val tagDetectedFilter = IntentFilter(NfcAdapter.ACTION_TAG_DISCOVERED)
        intentFiltersArray = arrayOf(ndefFilter, tagDetectedFilter)
        
        // Create tech lists
        techListsArray = arrayOf(
            arrayOf<String>(android.nfc.tech.NfcA::class.java.name),
            arrayOf<String>(android.nfc.tech.NfcB::class.java.name),
            arrayOf<String>(android.nfc.tech.NfcF::class.java.name),
            arrayOf<String>(android.nfc.tech.NfcV::class.java.name),
            arrayOf<String>(android.nfc.tech.Ndef::class.java.name),
            arrayOf<String>(android.nfc.tech.NdefFormatable::class.java.name),
            arrayOf<String>(android.nfc.tech.MifareClassic::class.java.name),
            arrayOf<String>(android.nfc.tech.MifareUltralight::class.java.name)
        )
    }
    
    fun isNFCEnabled(): Boolean {
        return nfcAdapter?.isEnabled == true
    }
    
    fun isNFCSupported(): Boolean {
        return nfcAdapter != null
    }
    
    fun enableForegroundDispatch() {
        nfcAdapter?.enableForegroundDispatch(
            activity,
            pendingIntent,
            intentFiltersArray,
            techListsArray
        )
    }
    
    fun disableForegroundDispatch() {
        nfcAdapter?.disableForegroundDispatch(activity)
    }
    
    fun handleNFCIntent(intent: Intent): NFCTagData? {
        val tag: Tag? = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
        
        return when (intent.action) {
            NfcAdapter.ACTION_NDEF_DISCOVERED -> {
                readNDEFMessage(intent)
            }
            NfcAdapter.ACTION_TAG_DISCOVERED -> {
                readTagInfo(tag)
            }
            NfcAdapter.ACTION_TECH_DISCOVERED -> {
                readTechInfo(tag)
            }
            else -> null
        }
    }
    
    private fun readNDEFMessage(intent: Intent): NFCTagData? {
        val rawMessages: Array<Parcelable>? = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)
        
        return rawMessages?.let { messages ->
            val ndefMessages = messages.map { it as NdefMessage }
            val records = ndefMessages.flatMap { it.records.toList() }
            
            val textRecords = records.mapNotNull { record ->
                if (record.tnf == NdefRecord.TNF_WELL_KNOWN &&
                    record.type.contentEquals(NdefRecord.RTD_TEXT)) {
                    parseTextRecord(record)
                } else null
            }
            
            NFCTagData(
                type = "NDEF",
                data = textRecords.joinToString("\n"),
                records = records.size,
                technologies = emptyList()
            )
        }
    }
    
    private fun parseTextRecord(record: NdefRecord): String {
        val payload = record.payload
        val textEncoding = if ((payload[0].toInt() and 128) == 0) "UTF-8" else "UTF-16"
        val languageCodeLength = payload[0].toInt() and 51
        
        return try {
            String(
                payload,
                languageCodeLength + 1,
                payload.size - languageCodeLength - 1,
                Charset.forName(textEncoding)
            )
        } catch (e: UnsupportedEncodingException) {
            "Error parsing text record"
        }
    }
    
    private fun readTagInfo(tag: Tag?): NFCTagData? {
        return tag?.let {
            val tagId = it.id.joinToString(":") { byte -> "%02x".format(byte) }
            val technologies = it.techList.toList()
            
            NFCTagData(
                type = "TAG",
                data = "Tag ID: $tagId",
                records = 1,
                technologies = technologies
            )
        }
    }
    
    private fun readTechInfo(tag: Tag?): NFCTagData? {
        return tag?.let {
            val technologies = it.techList.toList()
            val techInfo = technologies.joinToString("\n") { tech ->
                "Technology: ${tech.substringAfterLast('.')}"
            }
            
            NFCTagData(
                type = "TECH",
                data = techInfo,
                records = technologies.size,
                technologies = technologies
            )
        }
    }
    
    fun writeNDEFMessage(tag: Tag, message: String): Boolean {
        return try {
            val ndefRecord = createTextRecord(message, "en")
            val ndefMessage = NdefMessage(arrayOf(ndefRecord))
            
            val ndef = Ndef.get(tag)
            if (ndef != null) {
                ndef.connect()
                if (ndef.isWritable && ndef.maxSize >= ndefMessage.toByteArray().size) {
                    ndef.writeNdefMessage(ndefMessage)
                    ndef.close()
                    true
                } else {
                    ndef.close()
                    false
                }
            } else {
                // Try to format the tag
                val ndefFormatable = NdefFormatable.get(tag)
                if (ndefFormatable != null) {
                    ndefFormatable.connect()
                    ndefFormatable.format(ndefMessage)
                    ndefFormatable.close()
                    true
                } else {
                    false
                }
            }
        } catch (e: Exception) {
            false
        }
    }
    
    private fun createTextRecord(text: String, locale: String): NdefRecord {
        val langBytes = locale.toByteArray()
        val textBytes = text.toByteArray()
        val utfBit = 0 // 0 for UTF-8, 1 for UTF-16
        
        val payload = ByteArray(1 + langBytes.size + textBytes.size)
        payload[0] = (utfBit + langBytes.size).toByte()
        System.arraycopy(langBytes, 0, payload, 1, langBytes.size)
        System.arraycopy(textBytes, 0, payload, 1 + langBytes.size, textBytes.size)
        
        return NdefRecord(NdefRecord.TNF_WELL_KNOWN, NdefRecord.RTD_TEXT, ByteArray(0), payload)
    }
}

data class NFCTagData(
    val type: String,
    val data: String,
    val records: Int,
    val technologies: List<String>
)
```

### NFC Activity Implementation

**Complete NFC Activity:**

```kotlin
class NFCActivity : AppCompatActivity() {
    private lateinit var nfcManager: NFCManager
    private lateinit var statusTextView: TextView
    private lateinit var dataTextView: TextView
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_nfc)
        
        statusTextView = findViewById(R.id.statusTextView)
        dataTextView = findViewById(R.id.dataTextView)
        
        nfcManager = NFCManager(this)
        
        if (!nfcManager.isNFCSupported()) {
            statusTextView.text = "NFC not supported on this device"
            return
        }
        
        if (!nfcManager.isNFCEnabled()) {
            statusTextView.text = "NFC is disabled. Please enable NFC in settings."
            showNFCSettings()
        } else {
            statusTextView.text = "NFC enabled. Ready to scan tags."
        }
    }
    
    override fun onResume() {
        super.onResume()
        if (nfcManager.isNFCEnabled()) {
            nfcManager.enableForegroundDispatch()
        }
    }
    
    override fun onPause() {
        super.onPause()
        if (nfcManager.isNFCEnabled()) {
            nfcManager.disableForegroundDispatch()
        }
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        intent?.let { nfcIntent ->
            val tagData = nfcManager.handleNFCIntent(nfcIntent)
            tagData?.let { data ->
                displayTagData(data)
            }
        }
    }
    
    private fun displayTagData(tagData: NFCTagData) {
        val displayText = buildString {
            appendLine("Tag Type: ${tagData.type}")
            appendLine("Records: ${tagData.records}")
            appendLine("Technologies: ${tagData.technologies.joinToString(", ") { it.substringAfterLast('.') }}")
            appendLine("Data:")
            appendLine(tagData.data)
        }
        
        dataTextView.text = displayText
        statusTextView.text = "Tag detected and processed"
    }
    
    private fun showNFCSettings() {
        AlertDialog.Builder(this)
            .setTitle("NFC Required")
            .setMessage("This app requires NFC to function. Would you like to enable it?")
            .setPositiveButton("Settings") { _, _ ->
                startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
}
```

