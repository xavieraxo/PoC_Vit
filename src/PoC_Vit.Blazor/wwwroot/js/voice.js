// Web Speech API helper for STT (speech-to-text) and TTS (text-to-speech)
// Minimal, client-only MVP for Chrome/Edge.

window.voice = (function () {
    let recognizer = null;
    let onResultDotnetRef = null;
    let onStartCb = null;
    let onStopCb = null;

    function isSupported() {
        return 'webkitSpeechRecognition' in window || 'SpeechRecognition' in window;
    }

    function create() {
        const Ctor = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (!Ctor) {
            recognizer = null;
            return;
        }
        try {
            recognizer = new Ctor();
        } catch (_) {
            recognizer = null;
            return;
        }
        if (!recognizer) {
            return;
        }
        recognizer.lang = 'es-ES';
        recognizer.interimResults = false;
        recognizer.maxAlternatives = 1;

        recognizer.onresult = (e) => {
            try {
                const text = e.results?.[0]?.[0]?.transcript || '';
                if (onResultDotnetRef) {
                    onResultDotnetRef.invokeMethodAsync('OnVoiceResult', text);
                }
            } catch (_) {}
        };
        recognizer.onerror = (_) => {
            // Errors are surfaced visually por el banner de Razor; mantener JS en silencio
        };
        recognizer.onstart = () => { if (onStartCb) onStartCb(); };
        recognizer.onend = () => { if (onStopCb) onStopCb(); };
    }

    function start(dotnetRef) {
        if (!isSupported()) return;
        if (!recognizer) create();
        onResultDotnetRef = dotnetRef;
        try { recognizer.start(); } catch (_) { /* ignore if already started */ }
    }

    function stop() {
        try { recognizer && recognizer.stop(); } catch (_) { }
    }

    function speak(text) {
        if (!('speechSynthesis' in window)) return;
        if (!text) return;
        const u = new SpeechSynthesisUtterance(text);
        u.lang = 'es-ES';
        window.speechSynthesis.cancel();
        window.speechSynthesis.speak(u);
    }

    function setCallbacks(onStart, onStop) {
        onStartCb = onStart;
        onStopCb = onStop;
    }

    return {
        isSupported,
        start,
        stop,
        speak,
        setCallbacks
    };
})();


