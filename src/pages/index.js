import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header
      style={{
        padding: '4rem 0',
        textAlign: 'center',
      }}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div style={{marginTop: '1.5rem'}}>
          <Link
            className="button button--primary button--lg"
            to="/docs/intro">
            Browse Standards
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  return (
    <Layout description="Open standards for AI development by Differential AI Lab">
      <HomepageHeader />
    </Layout>
  );
}
