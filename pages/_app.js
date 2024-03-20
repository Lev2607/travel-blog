import Head from 'next/head';
import './globals.css'

export const metadata = {
  title: "Levent's Blog",
  description: "Lass ma reisen gehen",
};

function MyApp({ Component, pageProps }) {
  return (
    <>
      <Head>
        <title>{metadata.title}</title>
        <meta name="description" content={metadata.description} />
        <link href="https://fonts.googleapis.com/css2?family=Dancing+Script&family=Montserrat:wght@400;700&display=swap" rel="stylesheet" />
      </Head>
      <Component {...pageProps} />
    </>
  );
}

export default MyApp