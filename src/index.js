import 'bulma';

//
// highlight.js settings.
//

import hljs from 'highlight.js';
window.hljs = hljs; // https://github.com/elm-explorations/markdown#code-blocks

import 'highlight.js/styles/github.css';


//
// firebase settings.
//

import 'firebase/auth';
import firebase from 'firebase/app';
import * as firebaseui from 'firebaseui';
import 'firebaseui/dist/firebaseui.css';

import { Elm } from './elm/Main.elm';

const firebaseProjectId = process.env.FIREBASE_PROJECT_ID;

firebase.initializeApp({
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: `${firebaseProjectId}.firebaseapp.com`,
  projectId: firebaseProjectId,
  appId: process.env.FIREBASE_APP_ID,
  measurementId: process.env.FIREBASE_MEASUREMENT_ID
});

const bootElm = (idToken) => {
  const flags = {
    blogTitle: process.env.BLOG_TITLE,
    apiUrl: process.env.API_URL,
    idToken: idToken,
  };

  const app = Elm.Main.init({
    node: document.getElementById('elm-app'),
    flags: flags
  });

  app.ports.getDocumentText.subscribe((selector) => {
    const element = document.querySelector(selector)
    if (element) {
      const htmlText = element.innerHTML;
      app.ports.gotDocumentText.send(htmlText);
    }
  });
}

const bootAuthUI = () => {
  const ui = new firebaseui.auth.AuthUI(firebase.auth());
  ui.start('#firebaseui-auth-container', {
    signInFlow: 'popup',
    signInOptions: [
      {
        provider: firebase.auth.GithubAuthProvider.PROVIDER_ID,
        scopes: [],
      },    
    ],
  });
}

firebase.auth().onAuthStateChanged((user) => {
  if (user) {
    user.getIdToken().then(bootElm);
  } else {
    bootAuthUI();
  }
});
