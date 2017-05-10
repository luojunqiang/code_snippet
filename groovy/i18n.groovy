import java.text.NumberFormat
import java.util.*

// http://www.oracle.com/technetwork/java/javase/javase7locales-334809.html

def localeList = [
        [languageId: 'pt', countryId:'BR', languageName: 'Portuguese', countryName:'Brazil'],
        [languageId: 'es', countryId:'CL', languageName: 'Spanish', countryName:'Chile'],
        [languageId: 'es', countryId:'PE', languageName: 'Spanish', countryName:'Peru'],
        [languageId: 'es', countryId:'ES', languageName: 'Spanish', countryName:'Spain'],
        [languageId: 'es', countryId:'AR', languageName: 'Spanish', countryName:'Argentina'],
        [languageId: 'es', countryId:'MX', languageName: 'Spanish', countryName:'Mexico'],
        [languageId: 'en', countryId:'US', languageName: 'English', countryName:'United States'],
        /*
        [languageId: 'es', countryId:'US', languageName: 'Spanish', countryName:'United States'],
        [languageId: 'es', countryId:'CO', languageName: 'Spanish', countryName:'Colombia'],
        [languageId: 'es', countryId:'CR', languageName: 'Spanish', countryName:'Costa Rica'],
        [languageId: 'fr', countryId:'FR', languageName: 'French', countryName:'France'],
        */
    ]

num = 123456.78

def runLocaleTest(locale) {
    println ""
    def l = new Locale(locale.languageId, locale.countryId)
    println "== language:[${locale.languageName}], country:[${locale.countryName}], locale:[$l]"
    println "    number: ${NumberFormat.getNumberInstance(l).format(num)}"
    println "  currency: ${NumberFormat.getCurrencyInstance(l).format(num)}"
}

println "test number value is [$num]\n"
localeList.each { runLocaleTest(it) }
