from faker import Faker
import happybase
import random
import hashlib # not used here but could be useful for rowkey hashing.
#generating the hash value
def hash_prefix(s: str, length: int = 2) -> str:
    return hashlib.sha256(s.encode()).hexdigest()[:length]

fake = Faker()
#connects to the hbase server (must be running)
conn = happybase.Connection(host='localhost', port=9090)  # Update host if needed
conn.open()

table = conn.table('webpages')

domains = ['example.com', 'test.org', 'site.net', 'demo.io', 'sample.co']
html_sizes = ['<p>short</p>', '<div>' + 'medium content ' * 20 + '</div>', '<section>' + 'large content ' * 100 + '</section>']

# Track inlinks and outlinks
page_urls = []

# Generate pages
for i in range(20):
#picks a random domain , generates a fake slug and construcs the rowkey as domain/page-slug
    domain = random.choice(domains)
    slug = fake.slug()
    raw_key = f"{domain}/{slug}"
    prefix = hash_prefix(raw_key)  # e.g., "a7", "d4"
    rowkey = f"{prefix}-{raw_key}"  # final rowkey: "a7-example.com/some-page"

#randomly picks page content size, generates a fake title, Generates a realistic modified date within the past 120 days, Assigns a fake HTTP status.
    content = random.choice(html_sizes)
    title = fake.sentence()
    last_modified = fake.date_time_between(start_date='-120d', end_date='now').isoformat()
    status_code = random.choice(['200', '404', '500'])

    # Generate outlinks to random previous pages
    outlinks = random.sample(page_urls, k=min(len(page_urls), random.randint(0, 3)))
    page_urls.append(rowkey)

    # Add inlink reference for existing pages
    #For every outlink this page has, add a corresponding **inlink** in the other page
    for outlink in outlinks:
        table.put(outlink, {
            b'inlinks:from': rowkey.encode()
        })

    # Insert the current page into hbase
    table.put(rowkey, {
        b'content:html': content.encode(),
        b'metadata:title': title.encode(),
        b'metadata:status': status_code.encode(),
        b'metadata:last_modified': last_modified.encode(),
        b'metadata:content_size': str(len(content)).encode(),
        **{f'outlinks:to{j}'.encode(): link.encode() for j, link in enumerate(outlinks)}
    })

print("✅ Inserted 20 sample web pages.")