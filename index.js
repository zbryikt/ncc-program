var x$;x$=angular.module("main",[]),x$.controller("main",["$scope","$http"].concat(function(n,a){return n.channels=[],a({url:"data/104-11-02.json",method:"GET"}).success(function(a){var e,r,s,t,c,o,u,l=[];for(n.channels=[],e={},r=0,s=a.length;s>r;++r)t=a[r],(e[c=t[1]]||(e[c]=[])).push(t);for(o in e)u=e[o],l.push(n.channels.push({name:o,list:u}));return l})}));