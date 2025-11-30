Most of the bugs stem from React v18's batching state updates feature. Use ReactDOM's flushSync to opt out of it. But you can't put that function inside lifecycle methods.

***

Be careful when using intermediate triggers for useEffects.

A useEffect may run at a different time/order instead of the expected time/order. It may run when a state that is expected to have changed have not yet changed.

***

`useNavigate`'s `navigate` function does not request a full page reload

`window.location.href` does