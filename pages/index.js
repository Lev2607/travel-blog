import {useState, useEffect } from "react";
import Head from "next/head";
import Image from "next/image";
import styles from "./page.module.css";

export default function Home() {
  // Zustandsvariablen für die Kommentare und das aktuelle eingegebene Kommentar
  const [comments, setComments] = useState([]);
  const [newComment, setNewComment] = useState("");

  // Funktion zum Laden der Kommentare beim ersten Rendern der Komponente
  useEffect(() => {
    fetchComments();
  }, []);

  // Funktion zum Laden der Kommentare von der API
  const fetchComments = async () => {
    try {
      const response = await fetch("/api/comments");
      if (response.ok) {
        const data = await response.json();
        setComments(data);
      } else {
        console.error("Fehler beim Laden der Kommentare:", response.statusText);
      }
    } catch (error) {
      console.error("Fehler beim Laden der Kommentare:", error);
    }
  };

  // Funktion zum Absenden eines neuen Kommentars
  const submitComment = async (event) => {
    event.preventDefault();
    try {
      const response = await fetch("/api/comments", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ comment: newComment }),
      });
      if (response.ok) {
        // Kommentar erfolgreich gesendet, aktualisieren Sie die Kommentare
        fetchComments();
        setNewComment(""); // Leeren Sie das Textfeld nach dem Senden
      } else {
        console.error("Fehler beim Senden des Kommentars:", response.statusText);
      }
    } catch (error) {
      console.error("Fehler beim Senden des Kommentars:", error);
    }
  };

  return (
    <>
      <Head>
        <title>Levent's Blog</title>
        <meta name="description" content="Lass ma' reisen gehen" />
      </Head>
      <main className={styles.main}>
        <h1 className={styles.title}>Komm wir gehen jetzt einfach Reisen !</h1>
        <p className={styles.description}>
          Entdecke die Welt und schreibe deine Geschichte
        </p>
      <section className={styles.blogEntry}>
        <h2 className={styles.entryTitle}>Magisches Hawaii: Ein Paradies auf Erden</h2>
        <Image className={styles.centerImage} src="/images/pexels-recal-media-60217.jpg" alt="Bild aus Hawaii" width={800} height={350} />
        <blockquote className={styles.entryContent}>
        <p>
        <br />
        Aloha liebe Leser!<br />
        <br />
        Ich sitze hier an einem einsamen Strand auf der atemberaubenden Insel Hawaii und bin einfach sprachlos über die Schönheit dieses Ortes. Von den üppigen Regenwäldern bis zu den majestätischen Vulkanen bietet Hawaii eine unvergleichliche Vielfalt an Naturwundern, die jeden Besucher verzaubern. <br />
        <br /> 
        Meine Reise begann auf der Insel Oahu, wo ich die pulsierende Hauptstadt Honolulu erkundete und den berühmten Waikiki Beach besuchte. Der Anblick der Surfer, die auf den Wellen reiten, und die warme Brise, die durch die Palmen weht, sind einfach unvergesslich.<br /> 
        <br />
        Dann flog ich weiter nach Maui, wo ich die spektakuläre Road to Hana entlangfuhr und die atemberaubenden Wasserfälle und üppigen Tropenwälder bewunderte. Ein Besuch des Haleakalā-Nationalparks war definitiv ein Höhepunkt meiner Reise. Der Sonnenaufgang über dem Krater war einfach magisch.<br />
        <br />
        Nun bin ich auf Big Island angekommen und stehe vor dem beeindruckenden Anblick des aktiven Vulkans Kilauea. Die roten Lavaströme und die rauchenden Krater sind ein faszinierendes Naturschauspiel, das mich sprachlos macht.<br />
        <br />
        Aber Hawaii ist nicht nur für seine Natur bekannt, sondern auch für seine reiche Kultur und Gastfreundschaft. Ich habe die traditionelle hawaiianische Küche probiert und bin von den frischen Aromen und exotischen Zutaten begeistert. Die Einheimischen haben mich mit offenen Armen empfangen und mir Geschichten über ihre Traditionen und Bräuche erzählt.<br />
        <br />
        Während meiner Zeit hier habe ich gelernt, die Schönheit und Zerbrechlichkeit unserer Umwelt zu schätzen. Hawaii hat mein Herz erobert und ich weiß, dass ich eines Tages zurückkehren werde, um mehr von diesem paradiesischen Archipel zu entdecken.<br />
        <br />
        Mahalo und Aloha, Hawaii, du wirst immer einen besonderen Platz in meinem Herzen haben!<br />
        <br />
        Bis bald,<br />
        Levent
        </p>
        </blockquote>
        <br />
        <br />
        <h3 className={styles.commentsTitle}>Kommentare</h3>
        <div className={styles.comments}>
          {/* Anzeige der Kommentare */}
          {comments.length > 0 ? (
            comments.map((comment, index) => (
              <p key={index}>{comment}</p>
            ))
          ) : (
            <p>Noch keine Kommentare. Sei der Erste, der einen Kommentar abgibt!</p>
          )}
        </div>
        {/* Kommentar-Formular */}
        <form className={styles.commentForm} onSubmit={submitComment}>
          <textarea id="comment" name="comment" value={newComment} onChange={(e) => setNewComment(e.target.value)}></textarea>
          <button type="submit">Kommentar absenden</button>
        </form>
      </section>
    </main>
    </>
  );
}
