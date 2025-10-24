get
<-  { params: {} }
->  query

patch
<-  /:param			<-  data (direct)
->  params			->  body

post
<-  data (direct)
->  body

put
<-  data (direct)
->  body

delete
<-  /:param			<- { params: {} }
->  { params: {} }		-> query