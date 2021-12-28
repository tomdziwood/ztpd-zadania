import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

import java.io.IOException;

public class Main {

    public static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();

        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        EPDeployment deployment;
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            deployment = deploymentService.deploy(epCompiled);
        } catch (EPCompileException e) {
            throw new RuntimeException(e);
        } catch (EPDeployException e) {
            throw new RuntimeException(e);
        }

        return deployment;
    }

    public static void main(String[] args) throws IOException {
        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);

        /*
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select irstream spolka as X, kursOtwarcia as Y from KursAkcji.win:length(3) "
        );*/


        /*
        // 24.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select irstream spolka as X, kursOtwarcia as Y " +
                        "from KursAkcji.win:length(3) " +
                        "where spolka = 'Oracle'"
        );
//
//        ISTREAM : {X=Oracle, Y=12.25}
//        RSTREAM : {X=Oracle, Y=12.25}
//        ISTREAM : {X=Oracle, Y=11.82}
//        RSTREAM : {X=Oracle, Y=11.82}
//        ISTREAM : {X=Oracle, Y=10.86}
//        RSTREAM : {X=Oracle, Y=10.86}
//        ISTREAM : {X=Oracle, Y=10.89}
//        RSTREAM : {X=Oracle, Y=10.89}
//        ISTREAM : {X=Oracle, Y=10.29}
//        RSTREAM : {X=Oracle, Y=10.29}
//        ISTREAM : {X=Oracle, Y=10.95}
//        RSTREAM : {X=Oracle, Y=10.95}
//        ISTREAM : {X=Oracle, Y=11.23}
//        RSTREAM : {X=Oracle, Y=11.23}
//        ISTREAM : {X=Oracle, Y=10.79}
//
//        Odp.: Zdarzenie kursu Oracle'a ze strumienia wejsciowego pojawia sie zaraz nastepnie w strumieniu wyjsciowym,
//              poniewaz w trakcie pojawiaja sie zdarzenia kursow innych społek, ktore nie trafiaja do strumienia
//              wejsciowego, ale jednak przesuwaja okno. Po pojawieniu sie trzech innych społek, kurs Oracla co pojawil
//              sie na ISTREAM wypada z okna, przez co pojawia sie teraz w RSTREAM.
//
        */


        /*
        // 25.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select irstream data, spolka, kursOtwarcia " +
                        "from KursAkcji.win:length(3) " +
                        "where spolka = 'Oracle'"
        );
//
//        ISTREAM : {spolka=Oracle, data=Wed Sep 05 00:00:00 CEST 2001, kursOtwarcia=12.25}
//        RSTREAM : {spolka=Oracle, data=Wed Sep 05 00:00:00 CEST 2001, kursOtwarcia=12.25}
//        ISTREAM : {spolka=Oracle, data=Thu Sep 06 00:00:00 CEST 2001, kursOtwarcia=11.82}
//        RSTREAM : {spolka=Oracle, data=Thu Sep 06 00:00:00 CEST 2001, kursOtwarcia=11.82}
//        ISTREAM : {spolka=Oracle, data=Fri Sep 07 00:00:00 CEST 2001, kursOtwarcia=10.86}
//        RSTREAM : {spolka=Oracle, data=Fri Sep 07 00:00:00 CEST 2001, kursOtwarcia=10.86}
//        ISTREAM : {spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001, kursOtwarcia=10.89}
//        RSTREAM : {spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001, kursOtwarcia=10.89}
//        ISTREAM : {spolka=Oracle, data=Mon Sep 17 00:00:00 CEST 2001, kursOtwarcia=10.29}
//        RSTREAM : {spolka=Oracle, data=Mon Sep 17 00:00:00 CEST 2001, kursOtwarcia=10.29}
//        ISTREAM : {spolka=Oracle, data=Tue Sep 18 00:00:00 CEST 2001, kursOtwarcia=10.95}
//        RSTREAM : {spolka=Oracle, data=Tue Sep 18 00:00:00 CEST 2001, kursOtwarcia=10.95}
//        ISTREAM : {spolka=Oracle, data=Wed Sep 19 00:00:00 CEST 2001, kursOtwarcia=11.23}
//        RSTREAM : {spolka=Oracle, data=Wed Sep 19 00:00:00 CEST 2001, kursOtwarcia=11.23}
//        ISTREAM : {spolka=Oracle, data=Thu Sep 20 00:00:00 CEST 2001, kursOtwarcia=10.79}
//
        */


        /*
        // 26.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select irstream data, spolka, kursOtwarcia " +
                        "from KursAkcji(spolka='Oracle').win:length(3) "
        );
//
//        ISTREAM : {spolka=Oracle, data=Wed Sep 05 00:00:00 CEST 2001, kursOtwarcia=12.25}
//        ISTREAM : {spolka=Oracle, data=Thu Sep 06 00:00:00 CEST 2001, kursOtwarcia=11.82}
//        ISTREAM : {spolka=Oracle, data=Fri Sep 07 00:00:00 CEST 2001, kursOtwarcia=10.86}
//        ISTREAM : {spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001, kursOtwarcia=10.89}
//        RSTREAM : {spolka=Oracle, data=Wed Sep 05 00:00:00 CEST 2001, kursOtwarcia=12.25}
//        ISTREAM : {spolka=Oracle, data=Mon Sep 17 00:00:00 CEST 2001, kursOtwarcia=10.29}
//        RSTREAM : {spolka=Oracle, data=Thu Sep 06 00:00:00 CEST 2001, kursOtwarcia=11.82}
//        ISTREAM : {spolka=Oracle, data=Tue Sep 18 00:00:00 CEST 2001, kursOtwarcia=10.95}
//        RSTREAM : {spolka=Oracle, data=Fri Sep 07 00:00:00 CEST 2001, kursOtwarcia=10.86}
//        ISTREAM : {spolka=Oracle, data=Wed Sep 19 00:00:00 CEST 2001, kursOtwarcia=11.23}
//        RSTREAM : {spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001, kursOtwarcia=10.89}
//        ISTREAM : {spolka=Oracle, data=Thu Sep 20 00:00:00 CEST 2001, kursOtwarcia=10.79}
//        RSTREAM : {spolka=Oracle, data=Mon Sep 17 00:00:00 CEST 2001, kursOtwarcia=10.29}
//
         */


        /*
        // 27.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream data, spolka, kursOtwarcia " +
                        "from KursAkcji(spolka='Oracle').win:length(3) "
        );
//
//        ISTREAM : {spolka=Oracle, data=Wed Sep 05 00:00:00 CEST 2001, kursOtwarcia=12.25}
//        ISTREAM : {spolka=Oracle, data=Thu Sep 06 00:00:00 CEST 2001, kursOtwarcia=11.82}
//        ISTREAM : {spolka=Oracle, data=Fri Sep 07 00:00:00 CEST 2001, kursOtwarcia=10.86}
//        ISTREAM : {spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001, kursOtwarcia=10.89}
//        ISTREAM : {spolka=Oracle, data=Mon Sep 17 00:00:00 CEST 2001, kursOtwarcia=10.29}
//        ISTREAM : {spolka=Oracle, data=Tue Sep 18 00:00:00 CEST 2001, kursOtwarcia=10.95}
//        ISTREAM : {spolka=Oracle, data=Wed Sep 19 00:00:00 CEST 2001, kursOtwarcia=11.23}
//        ISTREAM : {spolka=Oracle, data=Thu Sep 20 00:00:00 CEST 2001, kursOtwarcia=10.79}
//
         */


        /*
        // 28.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream data, spolka, max(kursOtwarcia) " +
                        "from KursAkcji(spolka='Oracle').win:length(5) "
        );
//
//        ISTREAM : {max(kursOtwarcia)=12.25, spolka=Oracle, data=Wed Sep 05 00:00:00 CEST 2001}
//        ISTREAM : {max(kursOtwarcia)=12.25, spolka=Oracle, data=Thu Sep 06 00:00:00 CEST 2001}
//        ISTREAM : {max(kursOtwarcia)=12.25, spolka=Oracle, data=Fri Sep 07 00:00:00 CEST 2001}
//        ISTREAM : {max(kursOtwarcia)=12.25, spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001}
//        ISTREAM : {max(kursOtwarcia)=12.25, spolka=Oracle, data=Mon Sep 17 00:00:00 CEST 2001}
//        ISTREAM : {max(kursOtwarcia)=11.82, spolka=Oracle, data=Tue Sep 18 00:00:00 CEST 2001}
//        ISTREAM : {max(kursOtwarcia)=11.23, spolka=Oracle, data=Wed Sep 19 00:00:00 CEST 2001}
//        ISTREAM : {max(kursOtwarcia)=11.23, spolka=Oracle, data=Thu Sep 20 00:00:00 CEST 2001}
//
        */


        /*
        // 29.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream data, spolka, (kursOtwarcia - max(kursOtwarcia)) as roznica " +
                        "from KursAkcji(spolka='Oracle').win:length(5) "
        );
//
//        ISTREAM : {spolka=Oracle, data=Wed Sep 05 00:00:00 CEST 2001, roznica=0.0}
//        ISTREAM : {spolka=Oracle, data=Thu Sep 06 00:00:00 CEST 2001, roznica=-0.4300003}
//        ISTREAM : {spolka=Oracle, data=Fri Sep 07 00:00:00 CEST 2001, roznica=-1.3900003}
//        ISTREAM : {spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001, roznica=-1.3599997}
//        ISTREAM : {spolka=Oracle, data=Mon Sep 17 00:00:00 CEST 2001, roznica=-1.96}
//        ISTREAM : {spolka=Oracle, data=Tue Sep 18 00:00:00 CEST 2001, roznica=-0.8699999}
//        ISTREAM : {spolka=Oracle, data=Wed Sep 19 00:00:00 CEST 2001, roznica=0.0}
//        ISTREAM : {spolka=Oracle, data=Thu Sep 20 00:00:00 CEST 2001, roznica=-0.43999958}
//
//        Odp.: Funkcja max() w agreguje wartosci w obecnej relacji o zasiegu podanym przez rozmiar okna.
//              Poszczegolne proste pola (data, spolka, kursOtwarcia) odnosza sie tylko do rekordu, ktory wlasnie
//              podawany jest na wejsciowym strumienu.
//
        */


        // 30.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream data, spolka, max(kursOtwarcia) - min(kursOtwarcia) as roznica, kursOtwarcia, max(kursOtwarcia) " +
                        "from KursAkcji(spolka='Oracle').win:length(2) " +
                        "having kursOtwarcia - min(kursOtwarcia) > 0"
        );
//
//        ISTREAM : {max(kursOtwarcia)=10.89, spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001, roznica=0.030000687, kursOtwarcia=10.89}
//        ISTREAM : {max(kursOtwarcia)=10.95, spolka=Oracle, data=Tue Sep 18 00:00:00 CEST 2001, roznica=0.65999985, kursOtwarcia=10.95}
//        ISTREAM : {max(kursOtwarcia)=11.23, spolka=Oracle, data=Wed Sep 19 00:00:00 CEST 2001, roznica=0.27999973, kursOtwarcia=11.23}
//



        ProstyListener prostyListener = new ProstyListener();
        for (EPStatement statement : deployment.getStatements()) {
            statement.addListener(prostyListener);
        }

        InputStream inputStream = new InputStream();
        inputStream.generuj(epRuntime.getEventService());
    }
}
