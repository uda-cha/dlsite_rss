import type { NextPage } from 'next'
import Head from 'next/head'
import Image from 'next/image'
import styles from '../styles/Home.module.css'
import { Box, Card, CardActionArea, CardContent, Link, Typography } from '@mui/material'
import '@fontsource/roboto/300.css';
import '@fontsource/roboto/400.css';
import '@fontsource/roboto/500.css';
import '@fontsource/roboto/700.css';

const Home: NextPage = () => {
  return (
    <div className={styles.container}>
      <Head>
        <title>DLsite RSS Feed</title>
        <meta name="description" content="DLsite新着作品の非公式RSS配信サイト" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <Typography variant='h1'>
          DLsite RSS Feed
        </Typography>

        <Box my={8}>
          <Typography>
            DLsite新着作品の非公式RSS配信サイトです。
          </Typography>
        </Box>

        <Card>
          <CardActionArea>
            <CardContent>
              <Link
                href="https://dlsite-rss.s3-ap-northeast-1.amazonaws.com/voice_rss.xml"
                target="_blank"
                color="inherit"
                rel="noopener noreferrer"
                underline="none"
              >
                <Typography variant='h2' gutterBottom>Voice</Typography>
                <Typography>ボイス・ASMR・音楽の新着作品</Typography>
              </Link>
            </CardContent>
          </CardActionArea>
        </Card>
      </main>

      <footer className={styles.footer}>
        <Link
          href="https://github.com/uda-cha/dlsite_rss"
          target="_blank"
          rel="noopener noreferrer"
          underline="hover"
        >
          Maintained by{' '}
          <span>
            <Image src="/github.svg" alt="Github Logo" width={48} height={16} />
          </span>
          uda-cha/dlsite_rss
        </Link>
      </footer>
    </div>
  )
}

export default Home
